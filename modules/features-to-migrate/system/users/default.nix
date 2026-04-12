{ lib, unify, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) flatten;
  inherit (lib.options) mkOption;
in
{
  unify.features.system._.users =
    { host, __inputContexts, ... }:
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
              apply =
                contexts:
                unify.lib.collectContexts {
                  inherit (config) requires;
                  inherit contexts;
                  resolvedContexts = __inputContexts;
                };
              description = ''
                Contexts for this user.
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
          imports = flatten (
            mapAttrsToList (
              _: user:
              unify.lib.collectModules {
                class = "nixos";
                inherit (user) requires contexts;
              }
            ) host.users
          );
        };

      darwin =
        { ... }:
        {
          imports = flatten (
            mapAttrsToList (
              _: user:
              unify.lib.collectModules {
                class = "darwin";
                inherit (user) requires contexts;
              }
            ) host.users
          );
        };
    };
}
