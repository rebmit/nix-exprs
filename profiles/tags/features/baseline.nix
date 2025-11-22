{
  flake.unify.modules."tags/features/baseline" = {
    nixos = {
      meta = {
        requires = [
          # keep-sorted start
          "nix/common"
          "nix/gc"
          "nix/registry"
          "nix/settings"
          "programs/collections/common"
          "programs/git"
          "security/polkit"
          "security/sudo-rs"
          "services/dbus"
          "services/logrotate"
          "services/nscd"
          "system/boot/kernel/latest"
          "system/common"
          "system/documentation"
          "system/i18n"
          "system/time"
          "users/root"
          # keep-sorted end
        ];
      };
    };

    homeManager = {
      meta = {
        requires = [
          # keep-sorted start
          "home/documentation"
          "home/xdg-user-dirs"
          "nix/common"
          "programs/collections/common"
          "programs/helix"
          "programs/tmux"
          "programs/yazi"
          "programs/zoxide"
          # keep-sorted end
        ];
      };
    };
  };
}
