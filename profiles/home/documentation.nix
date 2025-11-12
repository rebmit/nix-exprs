{
  flake.unify.modules."home/documentation" = {
    homeManager = {
      meta = {
        tags = [ "baseline" ];
      };

      module = _: {
        programs.man.generateCaches = false;
      };
    };
  };
}
