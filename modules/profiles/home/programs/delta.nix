{
  unify.profiles.home._.programs._.delta =
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
