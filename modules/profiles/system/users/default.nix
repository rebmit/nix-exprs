{ lib, unify, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.options) mkOption;
in
{
  unify.profiles.system._.users =
    { host, ... }:
    let
      userType = types.submodule (
        { name, ... }:
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
            contexts.user = mkOption {
              type = types.deferredModule;
              default = { };
              description = ''
                User context for this user.
              '';
            };
          };
        }
      );
    in
    {
      requires = [ "profiles/system/users/home-manager" ];

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
              inherit (user) requires contexts;
              resolvedContexts.host = host;
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
              inherit (user) requires contexts;
              resolvedContexts.host = host;
            }
          ) host.users;
        };
    };
}
