{ lib, ... }:
let
  inherit (lib.lists) optionals;
in
{
  flake.unify.modules."misc/theme/adwaita" = {
    homeManager = {
      meta = {
        requires = [ "misc/theme/common" ];
      };

      module =
        { config, pkgs, ... }:
        {
          theme = {
            light = {
              # keep-sorted start block=yes
              base24Theme = config.lib.theme.importBase24Theme ./adwaita-light.toml;
              cursorSize = 36;
              cursorTheme = "capitaine-cursors-white";
              ghosttyTheme = "Adwaita";
              gtkTheme = "adw-gtk3";
              helixTheme = "${pkgs.helix}/lib/runtime/themes/adwaita-light.toml";
              iconTheme = "Papirus-Light";
              wallpaper = "${pkgs.nixos-artwork.wallpapers.nineish}/share/backgrounds/nixos/nix-wallpaper-nineish.png";
              # keep-sorted end
            };

            dark = {
              # keep-sorted start block=yes
              base24Theme = config.lib.theme.importBase24Theme ./adwaita-dark.toml;
              cursorSize = 36;
              cursorTheme = "capitaine-cursors";
              ghosttyTheme = "Adwaita Dark";
              gtkTheme = "adw-gtk3-dark";
              helixTheme = "${pkgs.helix}/lib/runtime/themes/adwaita-dark.toml";
              iconTheme = "Papirus-Dark";
              wallpaper = "${pkgs.nixos-artwork.wallpapers.nineish-dark-gray}/share/backgrounds/nixos/nix-wallpaper-nineish-dark-gray.png";
              # keep-sorted end
            };
          };

          home.packages =
            with pkgs;
            optionals stdenv.hostPlatform.isLinux [
              papirus-icon-theme
              capitaine-cursors
              adw-gtk3
            ];
        };
    };
  };
}
