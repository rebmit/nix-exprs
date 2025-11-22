{
  flake.unify.modules."misc/xdg/portal" = {
    nixos = {
      module =
        { ... }:
        {
          environment.pathsToLink = [ "/share/xdg-desktop-portal" ];
        };
    };
  };
}
