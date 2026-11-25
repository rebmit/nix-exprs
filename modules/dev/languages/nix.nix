{ lib, pkgs, ... }:

{ config, ... }:

let
  cfg = config.languages.nix;
in
{
  options.languages.nix = {
    enable = lib.mkEnableOption "tools for Nix development";
  };

  config = lib.mkIf cfg.enable {
    devshell.config = {
      devshell.packages = with pkgs; [ nixd ];
    };

    treefmt.config = {
      programs = {
        deadnix = {
          enable = true;
          no-underscore = true;
          no-lambda-arg = true;
          no-lambda-pattern-names = true;
        };

        nixfmt.enable = true;
      };
    };
  };
}
