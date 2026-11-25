{
  inputs,
  lib,
  pkgs,
  ...
}:

{ config, options, ... }:

let
  cfg = config.git-hooks;
in
{
  options.git-hooks = {
    enable = lib.mkEnableOption "git-hooks.nix integration";

    source = lib.mkOption {
      type = lib.types.pathInStore;
      default =
        inputs.git-hooks-nix or (throw ''
          `${options.git-hooks.source}` is used but is not set.

          Consider providing `inputs.git-hooks-nix` or explicitly setting `${options.git-hooks.source}`.
        '');
      description = ''
        git-hooks.nix source tree for evaluation.
      '';
    };

    config = lib.mkOption {
      type = lib.types.submoduleWith {
        modules = [
          (cfg.source + "/modules/all-modules.nix")
        ];
        specialArgs = { inherit pkgs; };
        shorthandOnlyDefinesConfig = true;
      };
      default = { };
      description = ''
        git-hooks.nix configuration.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    devshell.config.devshell.startup.pre-commit-hook.text = cfg.config.shellHook;

    git-hooks.config.package = lib.mkDefault pkgs.prek;
  };
}
