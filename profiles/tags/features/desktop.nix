{
  flake.unify.modules."tags/features/desktop" = {
    nixos = {
      meta = {
        requires = [
          # keep-sorted start
          "misc/fontconfig"
          "misc/xdg/portal"
          "security/pam/swaylock"
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
          # keep-sorted end
        ];
      };
    };
  };
}
