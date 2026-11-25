{
  inputs,
  lib,
  pkgs,
  ...
}:

{ config, options, ... }:

let
  cfg = config.treefmt;
in
{
  options.treefmt = {
    enable = lib.mkEnableOption "treefmt-nix integration";

    source = lib.mkOption {
      type = lib.types.pathInStore;
      default =
        inputs.treefmt-nix or (throw ''
          `${options.treefmt.source}` is used but is not set.

          Consider providing `inputs.treefmt-nix` or explicitly setting `${options.treefmt.source}`.
        '');
      description = ''
        treefmt-nix source tree for evaluation.
      '';
    };

    config = lib.mkOption {
      type = cfg.source.lib.submoduleWith lib {
        specialArgs = {
          inherit pkgs;
        };
      };
      default = { };
      description = ''
        treefmt-nix configuration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    devshell.config.commands = [
      {
        package = cfg.config.build.wrapper;
      }
    ];

    git-hooks.config.hooks.treefmt = {
      enable = true;
      name = "treefmt";
      entry = lib.getExe cfg.config.build.wrapper;
      pass_filenames = false;
    };

    treefmt.config.projectRootFile = lib.mkDefault "flake.nix";

    outputs.formatter = cfg.config.build.wrapper;
  };
}
