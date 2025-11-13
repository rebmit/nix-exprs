{
  flake.unify.modules."programs/delta" = {
    homeManager = {
      meta = {
        tags = [ "development" ];
      };

      module =
        { ... }:
        {
          programs.delta = {
            enable = true;
            enableGitIntegration = true;
          };
        };
    };
  };
}
