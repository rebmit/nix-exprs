{ lib, ... }:
let
  inherit (lib.meta) getExe;
in
{
  flake.unify.modules."services/user/waybar" = {
    homeManager = {
      module =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        let
          mkTheme =
            mode:
            let
              inherit (config.theme.${mode}) base24Theme;
            in
            pkgs.writeText "waybar-style-${mode}.css" (import ./_style.nix base24Theme);
        in
        {
          programs.waybar = {
            enable = true;
            systemd.enable = true;
          };

          systemd.user.services.waybar = {
            Unit = {
              Requisite = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
            };
          };

          systemd.user.tmpfiles.rules = [
            "L %h/.config/waybar/style.css - - - - ${mkTheme "light"}"
          ];

          services.darkman =
            let
              mkScript =
                mode:
                pkgs.writeShellApplication {
                  name = "darkman-switch-waybar-${mode}";
                  text = ''
                    ln --force --symbolic --verbose "${mkTheme mode}" "$HOME/.config/waybar/style.css"
                    pkill -u "$USER" -USR2 waybar || true
                  '';
                };
            in
            {
              lightModeScripts.waybar = "${getExe (mkScript "light")}";
              darkModeScripts.waybar = "${getExe (mkScript "dark")}";
            };

          programs.waybar.settings = [
            (
              {
                position = "top";
                modules-left = [
                  "custom/nixos"
                  "niri/workspaces"
                  "niri/window"
                ];
                modules-right = [
                  "pulseaudio"
                  "clock"
                  "tray"
                ];
              }
              // (import ./_common.nix { inherit config pkgs lib; })
            )
          ];
        };
    };
  };
}
