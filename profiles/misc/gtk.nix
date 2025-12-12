{ lib, ... }:
let
  inherit (lib.modules) mkForce;
  inherit (lib.meta) getExe;
in
{
  flake.unify.modules."misc/gtk" = {
    homeManager = {
      meta = {
        requires = [
          # keep-sorted start
          "misc/theme/common"
          "programs/dconf"
          "services/user/darkman"
          # keep-sorted end
        ];
      };

      module =
        { config, pkgs, ... }:
        {
          gtk = {
            enable = true;
            gtk2.enable = false;
          };

          # https://github.com/nix-community/home-manager/pull/5206
          # https://github.com/nix-community/home-manager/commit/e9b9ecef4295a835ab073814f100498716b05a96
          xdg.configFile."gtk-4.0/gtk.css" = mkForce {
            text = config.gtk.gtk4.extraCss;
          };

          home.sessionVariables = {
            GTK_USE_PORTAL = "1";
          };

          services.darkman =
            let
              mkScript =
                mode:
                let
                  inherit (config.theme.${mode})
                    gtkTheme
                    iconTheme
                    ;
                in
                pkgs.writeShellApplication {
                  name = "darkman-switch-gtk-${mode}";
                  runtimeInputs = with pkgs; [
                    dconf
                  ];
                  text = ''
                    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-${mode}'"
                    dconf write /org/gnome/desktop/interface/gtk-theme "'${gtkTheme}'"
                    dconf write /org/gnome/desktop/interface/icon-theme "'${iconTheme}'"
                  '';
                };
            in
            {
              lightModeScripts.gtk = "${getExe (mkScript "light")}";
              darkModeScripts.gtk = "${getExe (mkScript "dark")}";
            };
        };
    };
  };
}
