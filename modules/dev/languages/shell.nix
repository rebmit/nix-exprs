{ lib, pkgs, ... }:

{ config, ... }:

let
  cfg = config.languages.shell;
in
{
  options.languages.shell = {
    enable = lib.mkEnableOption "tools for shell development";
  };

  config = lib.mkIf cfg.enable {
    devshell.config = {
      devshell.packages = with pkgs; [ bash-language-server ];
    };

    treefmt.config = {
      programs = {
        shellcheck.enable = true;
        shfmt.enable = true;
      };
    };
  };
}
