{ lib, ... }:
let
  inherit (lib.meta) getExe;
in
{
  flake.unify.modules."services/user/swww" = {
    homeManager = {
      meta = {
        requires = [
          "misc/theme/common"
          "services/user/darkman"
        ];
      };

      module =
        {
          config,
          pkgs,
          ...
        }:
        {
          systemd.user.services.swww-daemon = {
            Unit = {
              Description = "A Solution to your Wayland Wallpaper Woes";
              Documentation = "https://github.com/LGFae/swww";
              PartOf = [ "graphical-session.target" ];
              After = [ "graphical-session.target" ];
              Requisite = [ "graphical-session.target" ];
            };

            Service = {
              ExecStart = "${pkgs.swww}/bin/swww-daemon --no-cache";
              ExecStartPost = "${pkgs.swww}/bin/swww img %h/.config/swww/wallpaper";
              Restart = "on-failure";
              KillMode = "mixed";
            };

            Install.WantedBy = [ "graphical-session.target" ];
          };

          systemd.user.tmpfiles.rules = [
            "L %h/.config/swww/wallpaper - - - - ${config.theme.light.wallpaper}"
          ];

          services.darkman =
            let
              mkScript =
                mode:
                pkgs.writeShellApplication {
                  name = "darkman-switch-swww-${mode}";
                  text = ''
                    ln --force --symbolic --verbose "${config.theme.${mode}.wallpaper}" "$HOME/.config/swww/wallpaper"
                    if ! ${config.systemd.user.systemctlPath} --user is-active swww-daemon; then
                      echo "swww-daemon is not active"
                      exit 1
                    fi
                    ${pkgs.swww}/bin/swww img ~/.config/swww/wallpaper
                  '';
                };
            in
            {
              lightModeScripts.swww = "${getExe (mkScript "light")}";
              darkModeScripts.swww = "${getExe (mkScript "dark")}";
            };
        };
    };
  };
}
