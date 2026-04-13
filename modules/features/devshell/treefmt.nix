{
  inputs,
  lib,
  pkgs,
  ...
}:

{ modules, dev, ... }:

let
  treefmt-nix = import dev.treefmt.path;
in
{
  configs.dev =
    { ... }:
    {
      options = {
        treefmt = {
          path = lib.mkOption {
            type = lib.types.path;
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
            default = (treefmt-nix.evalModule pkgs modules.treefmt).config;
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
          package = dev.treefmt.config.build.wrapper;
        }
      ];
    };

  modules.pre-commit =
    { ... }:
    {
      hooks.treefmt = {
        enable = true;
        name = "treefmt";
        entry = lib.getExe dev.treefmt.config.build.wrapper;
        pass_filenames = false;
      };
    };

  modules.treefmt =
    { ... }:
    {
      inherit (dev.treefmt) projectRootFile;
    };
}
