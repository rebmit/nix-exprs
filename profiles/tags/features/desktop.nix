{
  flake.unify.modules."tags/features/desktop" = {
    nixos = {
      meta = {
        requires = [
          # keep-sorted start
          "misc/fontconfig"
          "misc/xdg/portal"
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
          "programs/ghostty"
          "programs/niri"
          "services/user/darkman"
          # keep-sorted end
        ];
      };
    };
  };
}
