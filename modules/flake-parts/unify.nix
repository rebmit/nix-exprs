# https://github.com/vic/flake-aspects/blob/d0a226c84be2900d307aa1896e4e2c6e451844b2/nix/types.nix
{ lib, ... }:
let
  inherit (builtins) hashString toJSON;
  inherit (lib) types;
  inherit (lib.attrsets) genAttrs getAttrs mapAttrs;
  inherit (lib.options) mkOption;
  inherit (lib.trivial) pipe flip;

  mkProviderType =
    {
      contextAware ? true,
    }:
    types.submodule (
      {
        name,
        config,
        extendModules,
        ...
      }:
      {
        freeformType = types.lazyAttrsOf types.deferredModule;

        options = {
          name = mkOption {
            type = types.str;
            readOnly = true;
            default = name;
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
                  "name"
                  "contexts"
                  "requires"
                  "__functor"
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

  featureProviderType = mkProviderType { contextAware = false; };
  profileProviderType = mkProviderType { };

  unifyModule =
    { config, ... }:
    {
      options.unify = {
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

      config._module.args.unify = config.unify;
    };
in
{
  imports = [ unifyModule ];
}
