{ inputs, lib, ... }:

{
  modules,
  host ? null,
  user,
  ...
}:

let
  cfg = user.config.home;
in
{
  configs.user =
    { pkgs, ... }:
    {
      options = {
        home = {
          class = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.enum [
                "homeManager"
              ]
            );
            default = null;
            description = ''
              Module system class of the user.
            '';
          };

          config = lib.mkOption {
            type = lib.types.raw;
            readOnly = true;
            default =
              if cfg.class == null then
                throw "class must be set to evaluate a standalone home configuration"
              else
                {
                  "homeManager" = cfg.homeManager.config;
                }
                .${cfg.class};
            description = ''
              Evaluated standalone home configuration.
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

            config = lib.mkOption {
              type = lib.types.raw;
              readOnly = true;
              default = import (cfg.homeManager.path + "/modules") {
                inherit pkgs lib;

                configuration = {
                  imports = [
                    modules.homeManager

                    {
                      programs.home-manager = {
                        enable = true;
                        path = cfg.homeManager.path.outPath or cfg.homeManager.path;
                      };
                    }
                  ];
                };
              };
              description = ''
                Evaluated standalone home-manager configuration.
              '';
            };
          };
        };
      };

      config = {
        _module.args.pkgs = lib.mkDefault (throw ''
          `pkgs` was used but is not set.

          Consider including the Nixpkgs module or explicitly providing `pkgs`.
        '');

        home = {
          homeManager.path = lib.mkIf (host != null) (lib.mkForce host.config.users.homeManager.path);
        };
      };
    };

  modules.homeManager =
    { ... }:
    {
      home = {
        version = {
          revision = lib.rebmit.trivial.revisionFromPath cfg.homeManager.path;
        };
      };
    };
}
