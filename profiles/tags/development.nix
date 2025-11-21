{
  flake.unify.modules."tags/development" = {
    nixos = {
      meta = {
        requires = [ ];
      };
    };

    homeManager = {
      meta = {
        requires = [
          # keep-sorted start
          "home/xdg-user-dirs"
          "programs/direnv"
          "programs/git"
          # keep-sorted end
        ];
      };
    };
  };
}
