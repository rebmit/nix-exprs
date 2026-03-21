{ lib, ... }:
let
  inherit (builtins)
    attrNames
    attrValues
    concatMap
    concatStringsSep
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
    setAttrByPath
    optionalAttrs
    ;
  inherit (lib.lists) take drop flatten;
  inherit (lib.modules) mkAliasOptionModule mkMerge evalModules;
  inherit (lib.options) mkOption;
  inherit (lib.strings) splitString;
  inherit (lib.trivial) pipe flip;

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
    {
      inputs,
      config,
      unify,
      ...
    }:
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

      collectContexts =
        {
          requires ? [ ],
          contexts ? { },
          resolvedContexts ? { },
        }:
        let
          resolveContext =
            providerName: contextName:
            resolveWithFunc providerName (provider: (provider finalContexts).contexts.${contextName} or { });

          finalContexts =
            resolvedContexts
            // mapAttrs (
              contextName: context:
              (evalModules {
                modules = flatten [
                  context
                  internalContextModule
                  (map (flip resolveContext contextName) requires)
                ];
              }).config
            ) contexts;
        in
        finalContexts;

      collectModules =
        {
          class,
          requires ? [ ],
          contexts ? { },
        }:
        let
          resolveModule =
            providerName: resolveWithFunc providerName (provider: (provider contexts).${class} or { });
        in
        map resolveModule requires;

      providerType =
        { path, ... }:
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
                default = name;
                description = ''
                  Name of this provider.
                '';
              };
              path = mkOption {
                type = types.listOf types.str;
                readOnly = true;
                default = path ++ [ name ];
                description = ''
                  Path of this provider.
                '';
              };
              requires = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = ''
                  Name of providers that this provider depends on.

                  Required providers contribute their modules and context declarations
                  transitively to configurations that depend on this provider.
                '';
              };
              contexts = mkOption {
                type = types.lazyAttrsOf types.deferredModule;
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
              provides = mkOption {
                type = types.submodule {
                  freeformType = types.lazyAttrsOf (providerType {
                    inherit (config) path;
                  });
                };
                default = { };
                description = ''
                  Sub-providers associated with this provider.
                '';
              };
              passthru = mkOption {
                type = types.lazyAttrsOf types.raw;
                default = { };
                description = ''
                  A set of freeform attributes exposed by this provider.
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
                      specialArgs = contexts // {
                        __inputContexts = inputContexts;
                      };
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
                          key = concatStringsSep "/" config.path;
                          imports = [ ctx ];
                        }) v
                      else
                        {
                          _class = k;
                          key = "${concatStringsSep "/" config.path}@${hashString "sha256" (toJSON keys)}";
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

      classType =
        { path, ... }:
        types.submodule (
          { name, ... }:
          {
            freeformType = types.lazyAttrsOf (configType { path = path ++ [ name ]; } name);
          }
        );

      configType =
        { path, ... }:
        class:
        types.submodule (
          { name, config, ... }:
          {
            freeformType = types.lazyAttrsOf types.deferredModule;

            imports = [ (mkAliasOptionModule [ "_" ] [ "provides" ]) ];

            options = {
              name = mkOption {
                type = types.str;
                readOnly = true;
                default = name;
                description = ''
                  Name of this configuration.
                '';
              };
              path = mkOption {
                type = types.listOf types.str;
                readOnly = true;
                default = path ++ [ name ];
                description = ''
                  Path of this configuration.
                '';
              };
              class = mkOption {
                type = types.str;
                readOnly = true;
                default = class;
                description = ''
                  Module class of this configuration.
                '';
              };
              requires = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = ''
                  Name of providers that this configuration depends on.
                '';
              };
              contexts = mkOption {
                type = types.lazyAttrsOf types.deferredModule;
                default = { };
                apply =
                  contexts:
                  collectContexts {
                    inherit (config) requires;
                    inherit contexts;
                  };
                description = ''
                  Contexts for this configuration.
                '';
              };
              provides = mkOption {
                type = types.submodule {
                  freeformType = types.lazyAttrsOf (providerType {
                    inherit (config) path;
                  });
                };
                default = { };
                description = ''
                  Sub-providers associated with this configuration.
                '';
              };
              modules = mkOption {
                type = types.listOf types.raw;
                readOnly = true;
                default = collectModules {
                  inherit (config) class requires contexts;
                };
                description = ''
                  Resolved modules for this configuration.
                '';
              };
              result = mkOption {
                type = types.raw;
                default =
                  {
                    nixos = inputs.nixpkgs.lib.nixosSystem { inherit (config) modules; };
                    darwin = inputs.nix-darwin.lib.darwinSystem { inherit (config) modules; };
                    homeManager = inputs.home-manager.lib.homeManagerConfiguration { inherit (config) modules; };
                  }
                  .${config.class};
                description = ''
                  Evaluated result of this configuration.
                '';
              };
              intoAttr = mkOption {
                type = types.listOf types.str;
                default =
                  {
                    nixos = [
                      "nixosConfigurations"
                      config.name
                    ];
                    darwin = [
                      "darwinConfigurations"
                      config.name
                    ];
                    homeManager = [
                      "homeConfigurations"
                      config.name
                    ];
                  }
                  .${config.class};
                description = ''
                  Flake attribute path for the result.
                '';
              };
            };
          }
        );
    in
    {
      _file = ./unify.nix;

      options.unify = {
        lib = mkOption {
          type = types.raw;
          readOnly = true;
          default = {
            inherit getProviderFromName collectContexts collectModules;
          };
          description = ''
            A set of helper functions for unify.
          '';
        };

        features = mkOption {
          type = types.submodule {
            freeformType = types.lazyAttrsOf (providerType {
              path = [ "features" ];
            });
          };
          default = { };
          description = ''
            A set of feature providers.
          '';
        };

        profiles = mkOption {
          type = types.submodule {
            freeformType = types.lazyAttrsOf (providerType {
              path = [ "profiles" ];
            });
          };
          default = { };
          description = ''
            A set of profile providers.
          '';
        };

        configs = mkOption {
          type = types.submodule {
            freeformType = types.lazyAttrsOf (classType {
              path = [ "configs" ];
            });
          };
          default = { };
          description = ''
            A set of configurations, grouped by module class.
          '';
        };
      };

      config = {
        _module.args.unify = config.unify;

        flake =
          let
            configs = flatten (map attrValues (attrValues unify.configs));
            build = cfg: optionalAttrs (cfg.intoAttr != [ ]) (setAttrByPath cfg.intoAttr cfg.result);
          in
          mkMerge (map build configs);
      };
    };
in
{
  imports = [ unifyModule ];

  flake.flakeModules.unify = unifyModule;
}
