{
  flake.unify.modules."programs/git" = {
    nixos = {
      module =
        { ... }:
        {
          programs.git = {
            enable = true;
            lfs.enable = true;
          };
        };
    };

    homeManager = {
      meta = {
        requires = [ "programs/delta" ];
      };

      module =
        { ... }:
        {
          programs.git = {
            enable = true;
            lfs.enable = true;
            settings = {
              commit.verbose = true;
              diff.algorithm = "patience";
              fetch.prune = true;
              init.defaultBranch = "master";
              merge.conflictStyle = "zdiff3";
              pull.rebase = true;
              rebase = {
                autoSquash = true;
                autoStash = true;
              };
            };
          };
        };
    };
  };
}
