{
  flake.unify.modules."home/documentation" = {
    homeManager = {
      meta = {
        tags = [ "baseline" ];
      };

      module =
        { ... }:
        {
          programs.man.generateCaches = false;
        };
    };
  };
}
