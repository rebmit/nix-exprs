{
  flake.unify.modules."home/documentation" = {
    homeManager = {
      module =
        { ... }:
        {
          programs.man.generateCaches = false;
        };
    };
  };
}
