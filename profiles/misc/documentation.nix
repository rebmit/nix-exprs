{
  flake.unify.modules."misc/documentation" = {
    nixos = {
      module =
        { ... }:
        {
          documentation = {
            enable = true;
            doc.enable = false;
            info.enable = false;
            man = {
              enable = true;
              generateCaches = false;
              man-db.enable = true;
            };
            nixos.enable = false;
          };
        };
    };

    homeManager = {
      module =
        { ... }:
        {
          programs.man.generateCaches = false;
        };
    };
  };
}
