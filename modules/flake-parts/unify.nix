# https://github.com/vic/flake-aspects/blob/d0a226c84be2900d307aa1896e4e2c6e451844b2/nix/types.nix
{ lib, ... }:
let
  inherit (builtins)
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
  inherit (lib.modules) mkAliasOptionModule;
  inherit (lib.options) mkOption;
  inherit (lib.strings) splitString;
  inherit (lib.trivial) pipe flip;

  mkProviderType =
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
          contexts = mkOption {
            type = types.listOf types.str;
            readOnly = !contextAware;
            default = [ ];
            description = ''
              A list of required context names for this provider.
            '';
          };
          requires = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = ''
              Names of providers that this provider depends on.
            '';
          };
          provides = mkOption {
            type = types.submodule {
              freeformType = types.lazyAttrsOf (mkProviderType (attrs // { namePrefix = config.name; }));
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
                contexts = getAttrs config.contexts inputContexts;
                eval = extendModules {
                  specialArgs = contexts;
                };
              in
              pipe eval.config [
                (flip removeAttrs [
                  # keep-sorted start
                  "_"
                  "__functor"
                  "contexts"
                  "name"
                  "provides"
                  "requires"
                  # keep-sorted end
                ])
                (mapAttrs (
                  k: v: {
                    _class = k;
                    key = "${config.name}@${hashString "sha256" (toJSON contexts)}";
                    imports = [ v ];
                  }
                ))
              ];
            description = ''
              Functor used to evaluate the provider with the given contexts.
            '';
          };
        };

        config._module.args = genAttrs config.contexts (
          ctx:
          throw ''
            Missing required context `${ctx}` for this provider.
            Required contexts must be provided via functor arguments.
          ''
        );
      }
    );

  featureProviderType = mkProviderType {
    contextAware = false;
    namePrefix = "features";
  };

  profileProviderType = mkProviderType { namePrefix = "profiles"; };

  getProviderFromName =
    unify: name:
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
    unify:
    {
      class,
      providerNames ? [ ],
      contexts ? { },
    }:
    let
      resolve =
        providerName:
        let
          provider = getProviderFromName unify providerName;
        in
        {
          imports = flatten [
            ((provider contexts).${class} or { })
            (map resolve provider.requires)
          ];
        };
    in
    {
      imports = map resolve providerNames;
    };

  unifyModule =
    { config, unify, ... }:
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

        unify.lib = mapAttrs (_: f: f unify) {
          inherit getProviderFromName collectModules;
        };
      };
    };
in
{
  imports = [ unifyModule ];
}
