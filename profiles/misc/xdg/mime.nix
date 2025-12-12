{
  flake.unify.modules."misc/xdg/mime" = {
    nixos = {
      module =
        { ... }:
        {
          environment.pathsToLink = [ "/share/mime" ];
        };
    };
  };
}
