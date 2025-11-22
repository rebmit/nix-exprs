{
  flake.unify.modules."tags/features/development" = {
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
          "programs/gdb"
          "programs/git"
          # keep-sorted end
        ];
      };
    };
  };
}
