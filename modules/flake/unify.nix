{ lib, ... }:
let
  inherit (builtins)
    attrNames
    concatMap
    hashString
    length
    mapAttrs
    toJSON
    ;
  inherit (lib) types;
  inherit (lib.attrsets)
    genAttrs
    getAttrs
    getAttrFromPath
    ;
  inherit (lib.lists) take drop flatten;
  inherit (lib.modules) mkAliasOptionModule evalModules;
  inherit (lib.options) mkOption;
  inherit (lib.strings) splitString;
  inherit (lib.trivial) pipe flip;

  providerType =
    {
      namePrefix,
      contextAware ? true,
    }@attrs:
    types.submodule (
      {
        name,
        config,
        extendModules,
        ...
      }:
      {
        freeformType = types.lazyAttrsOf types.deferredModule;

        imports = [ (mkAliasOptionModule [ "_" ] [ "provides" ]) ];

        options = {
          name = mkOption {
            type = types.str;
            readOnly = true;
            default = "${namePrefix}/${name}";
            description = ''
              Name of this provider.
            '';
          };
          path = mkOption {
            type = types.listOf types.str;
            readOnly = true;
            default = splitString "/" config.name;
            description = ''
              Path of this provider.
            '';
          };
          contexts = mkOption {
            type = types.lazyAttrsOf types.deferredModule;
            readOnly = !contextAware;
            default = { };
            description = ''
              Contexts required by this provider.

              Each attribute name declares a required context. The corresponding value
              is a module that will be imported into that context's module system, typically
              to declare options that this provider expects the context to provide.

              Context modules from all required providers are collected transitively and
              automatically imported into the corresponding contexts of configurations
              that depend on this provider.

              Declared contexts become available as arguments to this provider when
              evaluating the provider's class modules (e.g. nixos, darwin).
            '';
          };
          requires = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = ''
              Names of providers that this provider depends on.

              Required providers contribute their modules and context declarations
              transitively to configurations that depend on this provider.
            '';
          };
          passthru = mkOption {
            type = types.lazyAttrsOf types.raw;
            default = { };
            description = ''
              A set of freeform attributes exposed by this provider.
            '';
          };
          provides = mkOption {
            type = types.submodule {
              freeformType = types.lazyAttrsOf (providerType (attrs // { namePrefix = config.name; }));
            };
            default = { };
            description = ''
              Sub-providers associated with this provider.
            '';
          };
          __functor = mkOption {
            internal = true;
            visible = false;
            readOnly = true;
            default =
              _: inputContexts:
              let
                contexts = getAttrs (attrNames config.contexts) inputContexts;
                eval = extendModules {
                  specialArgs = contexts;
                };
                keys = mapAttrs (_: v: v.key) contexts;
              in
              pipe eval.config [
                (flip removeAttrs [
                  # keep-sorted start
                  "_"
                  "__functor"
                  "name"
                  "passthru"
                  "path"
                  "provides"
                  "requires"
                  # keep-sorted end
                ])
                (mapAttrs (
                  k: v:
                  if k == "contexts" then
                    mapAttrs (_: ctx: {
                      key = config.name;
                      imports = [ ctx ];
                    }) v
                  else
                    {
                      _class = k;
                      key = "${config.name}@${hashString "sha256" (toJSON keys)}";
                      imports = [ v ];
                    }
                ))
              ];
            description = ''
              Functor used to evaluate the provider with the given contexts.
            '';
          };
        };

        config._module.args =
          genAttrs (attrNames config.contexts) (
            ctx:
            throw ''
              Missing required context `${ctx}` for this provider.
              Required contexts must be provided via functor arguments.
            ''
          )
          // {
            provider = config;
          };
      }
    );

  featureProviderType = providerType {
    contextAware = false;
    namePrefix = "features";
  };

  profileProviderType = providerType { namePrefix = "profiles"; };

  internalContextModule =
    { ... }:
    {
      options = {
        key = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = ''
            An optional key used to distinguish different realizations of the same context.
          '';
        };
      };
    };

  unifyModule =
    { config, unify, ... }:
    let
      getProviderFromName =
        name:
        let
          parts = splitString "/" name;
        in
        if length parts < 2 then
          throw ''
            Invalid provider name `${name}`.
            Expected at least two path segments, e.g. `features/foo`.
          ''
        else
          let
            prefix = take 2 parts;
            rest = drop 2 parts;
            attrPath =
              prefix
              ++ concatMap (part: [
                "provides"
                part
              ]) rest;
          in
          getAttrFromPath attrPath unify;

      collectModules =
        {
          class,
          requires ? [ ],
          contexts ? { },
        }:
        let
          resolveWithFunc =
            providerName: func:
            let
              provider = getProviderFromName providerName;
            in
            {
              imports = flatten [
                (func provider)
                (map (flip resolveWithFunc func) provider.requires)
              ];
            };

          resolveContext =
            providerName: contextName:
            resolveWithFunc providerName (provider: (provider finalContexts).contexts.${contextName} or { });

          finalContexts = mapAttrs (
            contextName: context:
            (evalModules {
              modules = flatten [
                context
                internalContextModule
                (map (flip resolveContext contextName) requires)
              ];
            }).config
          ) contexts;

          resolveModule =
            providerName: resolveWithFunc providerName (provider: (provider finalContexts).${class} or { });
        in
        {
          imports = map resolveModule requires;
        };
    in
    {
      options.unify = {
        lib = mkOption {
          readOnly = true;
          description = ''
            A set of helper functions for unify.
          '';
        };

        features = mkOption {
          type = types.submodule {
            freeformType = types.lazyAttrsOf featureProviderType;
          };
          default = { };
          description = ''
            A set of feature providers.

            Feature providers are context-free and must not declare any required contexts.
          '';
        };

        profiles = mkOption {
          type = types.submodule {
            freeformType = types.lazyAttrsOf profileProviderType;
          };
          default = { };
          description = ''
            A set of profile providers.

            Profile providers may declare required contexts.
          '';
        };
      };

      config = {
        _module.args.unify = config.unify;

        unify.lib = {
          inherit getProviderFromName collectModules;
        };
      };
    };
in
{
  imports = [ unifyModule ];
}
