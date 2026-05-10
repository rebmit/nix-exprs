{
  inputs,
  lib,
  registry,
  __findFile,
  ...
}:

{ project, host, ... }:

let
  users = host.config.users;

  homeManagerFor =
    class:
    let
      hasHomeManager = user: user.config.configs.user.config.home.class == "homeManager";
    in
    lib.optionalAttrs (lib.any hasHomeManager (lib.attrValues users.users)) {
      imports = [
        {
          nixos = users.homeManager.path + "/nixos";
          darwin = users.homeManager.path + "/nix-darwin";
        }
        .${class}
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users = lib.mapAttrs (
          _: user: lib.optionalAttrs (hasHomeManager user) user.config.modules.homeManager
        ) users.users;
      };
    };

  moduleFor = class: {
    imports = lib.mapAttrsToList (_: user: user.config.modules.${class} or { }) users.users ++ [
      (homeManagerFor class)
    ];
  };
in
{
  configs.host =
    { ... }:
    {
      options = {
        users = {
          users = lib.mkOption {
            type = lib.types.lazyAttrsOf (
              lib.rebmit.types.latticeSubmodule (
                { name, ... }:
                {
                  includes = [ <rebmit/profiles/user/minimal> ];
                  excludes = [ ];
                  internalConfigs = [ "user" ];
                  externalConfigs = { inherit project host; };
                  inputs = { inherit name inputs lib; };
                  registry = registry;
                }
              )
            );
            default = { };
            description = ''
              User configurations.
            '';
          };

          homeManager = {
            path = lib.mkOption {
              type = lib.types.path;
              default = inputs.home-manager;
              description = ''
                home-manager source tree path for evaluation.
              '';
            };
          };
        };
      };
    };

  modules.darwin = moduleFor "darwin";

  modules.nixos = moduleFor "nixos";
}
