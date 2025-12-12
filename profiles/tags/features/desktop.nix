{
  flake.unify.modules."tags/features/desktop" = {
    nixos = {
      meta = {
        requires = [
          # keep-sorted start
          "misc/fontconfig"
          "misc/xdg/autostart"
          "misc/xdg/icons"
          "misc/xdg/portal"
          "security/pam/swaylock"
          "services/gnome-keyring"
          "services/greetd"
          # keep-sorted end
        ];
      };
    };

    homeManager = {
      meta = {
        requires = [
          # keep-sorted start
          "misc/fontconfig"
          "misc/gtk"
          "misc/qt"
          "misc/theme/adwaita"
          "programs/collections/desktop"
          "programs/dconf"
          "programs/fcitx5"
          "programs/firefox"
          "programs/fuzzel"
          "programs/ghostty"
          "programs/mako"
          "programs/niri"
          "programs/swaylock"
          "services/user/cliphist"
          "services/user/darkman"
          "services/user/polkit-gnome"
          "services/user/swww"
          "services/user/waybar"
          # keep-sorted end
        ];
      };
    };
  };
}
