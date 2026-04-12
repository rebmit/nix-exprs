{
  unify.features.home._.programs._.git =
    { ... }:
    {
      homeManager =
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
}
