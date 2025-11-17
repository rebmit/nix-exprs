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
          "home/preservation"
          "programs/delta"
          "programs/direnv"
          "programs/git"
          # keep-sorted end
        ];
      };
    };
  };
}
