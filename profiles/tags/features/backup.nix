{
  flake.unify.modules."tags/features/backup" = {
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
