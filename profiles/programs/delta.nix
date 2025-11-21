{
  flake.unify.modules."programs/delta" = {
    homeManager = {
      module =
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
  };
}
