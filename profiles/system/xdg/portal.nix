{
  flake.unify.modules."system/xdg/portal" = {
    nixos = {
      module =
        { ... }:
        {
          environment.pathsToLink = [ "/share/xdg-desktop-portal" ];
        };
    };
  };
}
