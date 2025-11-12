{
  flake.unify.modules."programs/delta" = {
    homeManager = {
      meta = {
        tags = [ "development" ];
      };

      module = _: {
        programs.delta = {
          enable = true;
          enableGitIntegration = true;
        };
      };
    };
  };
}
