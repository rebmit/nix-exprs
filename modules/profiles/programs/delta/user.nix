{
  unify.profiles.programs._.delta._.user =
    { ... }:
    {
      homeManager =
        { ... }:
        {
          programs.delta = {
            enable = true;
            enableGitIntegration = true;
            options = {
              line-numbers = true;
              navigate = true;
            };
          };
        };
    };
}
