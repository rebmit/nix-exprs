{
  unify.profiles.programs._.git._.user =
    { ... }:
    {
      requires = [ "profiles/programs/delta/user" ];

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
