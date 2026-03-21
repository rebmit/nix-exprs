{ lib, unify, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.options) mkOption;
in
{
  unify.features.system._.users =
    { host, inputContexts, ... }:
    let
      userType = types.submodule (
        { name, config, ... }:
        {
          options = {
            name = mkOption {
              type = types.str;
              readOnly = true;
              default = name;
              description = ''
                Name of this user.
              '';
            };
            class = mkOption {
              type = types.nullOr (types.enum [ "homeManager" ]);
              default = null;
              description = ''
                Module class to load for this user.
              '';
            };
            requires = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = ''
                Name of providers that this user depends on.
              '';
            };
            contexts = mkOption {
              type = types.lazyAttrsOf types.deferredModule;
              default = { };
              description = ''
                Additional per-user contexts for this user.
              '';
            };
            resolvedContexts = mkOption {
              type = types.lazyAttrsOf types.raw;
              readOnly = true;
              default = unify.lib.collectContexts {
                inherit (config) requires contexts;
                resolvedContexts = inputContexts;
              };
              description = ''
                Fully resolved contexts for this user.
              '';
            };
          };
        }
      );
    in
    {
      requires = [ "features/system/users/home-manager" ];

      contexts.host = {
        options.users = mkOption {
          type = types.lazyAttrsOf userType;
          default = { };
          description = ''
            Users defined for this host.
          '';
        };
      };

      nixos =
        { ... }:
        {
          imports = mapAttrsToList (
            _: user:
            unify.lib.collectModules {
              class = "nixos";
              inherit (user) requires resolvedContexts;
            }
          ) host.users;
        };

      darwin =
        { ... }:
        {
          imports = mapAttrsToList (
            _: user:
            unify.lib.collectModules {
              class = "darwin";
              inherit (user) requires resolvedContexts;
            }
          ) host.users;
        };
    };
}
