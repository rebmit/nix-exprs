{
  inputs,
  lib,
  pkgs,
  ...
}:

{ modules, dev, ... }:

let
  cfg = dev.config.treefmt;
in
{
  configs.dev =
    { ... }:
    {
      options = {
        treefmt = {
          path = lib.mkOption {
            type = lib.types.pathInStore;
            default = inputs.treefmt-nix;
            description = ''
              Path to the treefmt-nix source tree to be imported.
            '';
          };
          projectRootFile = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = ".git/config";
            description = ''
              File to look for to determine the root of the project.
            '';
          };
          config = lib.mkOption {
            type = lib.types.raw;
            readOnly = true;
            default = ((import cfg.path).evalModule pkgs modules.treefmt).config;
            description = ''
              Evaluated treefmt configuration.
            '';
          };
        };
      };
    };

  modules.devshell =
    { ... }:
    {
      commands = [
        {
          package = cfg.config.build.wrapper;
        }
      ];
    };

  modules.pre-commit =
    { ... }:
    {
      hooks.treefmt = {
        enable = true;
        name = "treefmt";
        entry = lib.getExe cfg.config.build.wrapper;
        pass_filenames = false;
      };
    };

  modules.treefmt =
    { ... }:
    {
      inherit (cfg) projectRootFile;
    };
}
