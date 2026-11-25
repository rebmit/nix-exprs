{
  inputs,
  lib,
  pkgs,
  ...
}:

{ config, options, ... }:

let
  cfg = config.devshell;
in
{
  options.devshell = {
    enable = lib.mkEnableOption "devshell integration" // {
      default = true;
    };

    source = lib.mkOption {
      type = lib.types.pathInStore;
      default =
        inputs.devshell or (throw ''
          `${options.devshell.source}` is used but is not set.

          Consider providing `inputs.devshell` or explicitly setting `${options.devshell.source}`.
        '');
      description = ''
        devshell source tree for evaluation.
      '';
    };

    config = lib.mkOption {
      type = lib.types.submoduleWith (
        import (cfg.source + "/modules/eval-args.nix") { inherit lib pkgs; }
      );
      default = { };
      description = ''
        devshell configuration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    outputs.shell = cfg.config.devshell.shell;
  };
}
