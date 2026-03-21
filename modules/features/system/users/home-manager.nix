{
  inputs,
  lib,
  unify,
  ...
}:
let
  inherit (lib.attrsets) filterAttrs mapAttrs optionalAttrs;
in
{
  unify.features.system._.users._.home-manager =
    { host, ... }:
    let
      filteredUsers = filterAttrs (_: user: user.class == "homeManager") host.users;
    in
    {
      contexts.host = { };

      nixos =
        { ... }:
        optionalAttrs (filteredUsers != { }) {
          imports = [ inputs.home-manager.nixosModules.home-manager ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users = mapAttrs (
              _: user:
              unify.lib.collectModules {
                class = "homeManager";
                inherit (user) requires resolvedContexts;
              }
            ) filteredUsers;
          };
        };

      darwin =
        { ... }:
        optionalAttrs (filteredUsers != { }) {
          imports = [ inputs.home-manager.darwinModules.home-manager ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users = mapAttrs (
              _: user:
              unify.lib.collectModules {
                class = "homeManager";
                inherit (user) requires resolvedContexts;
              }
            ) filteredUsers;
          };
        };
    };
}
