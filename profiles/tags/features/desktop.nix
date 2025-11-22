{
  flake.unify.modules."tags/features/desktop" = {
    nixos = {
      meta = {
        requires = [
          # keep-sorted start
          "security/pam/swaylock"
          "services/greetd"
          # keep-sorted end
        ];
      };
    };

    homeManager = {
      meta = {
        requires = [ ];
      };
    };
  };
}
