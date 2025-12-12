# Portions of this file are sourced from
# https://github.com/NickCao/flakes/blob/3b03efb676ea602575c916b2b8bc9d9cd13b0d85/nixos/mainframe/home.nix (MIT License)
{ lib, ... }:
let
  inherit (lib.meta) getExe;
in
{
  flake.unify.modules."programs/swaylock" = {
    homeManager = {
      meta = {
        requires = [
          "misc/theme/common"
          "services/user/darkman"
        ];
      };

      module =
        { config, pkgs, ... }:
        let
          mkBlurredWallpaper =
            mode:
            pkgs.runCommand "wallpaper-blurred-${mode}" { nativeBuildInputs = with pkgs; [ imagemagick ]; } ''
              magick ${config.theme.${mode}.wallpaper} -blur 14x5 $out
            '';
        in
        {
          programs.swaylock = {
            enable = true;
            settings = {
              show-failed-attempts = true;
              daemonize = true;
              image = "~/.config/swaylock/image";
              scaling = "fill";
            };
          };

          systemd.user.tmpfiles.rules = [
            "L %h/.config/swaylock/image - - - - ${mkBlurredWallpaper "light"}"
          ];

          services.darkman =
            let
              mkScript =
                mode:
                pkgs.writeShellApplication {
                  name = "darkman-switch-swaylock-${mode}";
                  text = ''
                    ln --force --symbolic --verbose "${mkBlurredWallpaper mode}" "$HOME/.config/swaylock/image"
                  '';
                };
            in
            {
              lightModeScripts.swaylock = "${getExe (mkScript "light")}";
              darkModeScripts.swaylock = "${getExe (mkScript "dark")}";
            };
        };
    };
  };
}
