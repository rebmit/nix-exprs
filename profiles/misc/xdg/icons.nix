{
  flake.unify.modules."misc/xdg/icons" = {
    nixos = {
      module =
        { ... }:
        {
          environment.pathsToLink = [
            "/share/icons"
            "/share/pixmaps"
          ];
        };
    };
  };
}
