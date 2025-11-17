{
  flake.unify.modules."tags/backup" = {
    nixos = {
      meta = {
        requires = [
          # keep-sorted start
          "services/restic"
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
