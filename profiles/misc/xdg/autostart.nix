{
  flake.unify.modules."misc/xdg/autostart" = {
    nixos = {
      module =
        { ... }:
        {
          environment.pathsToLink = [
            "/etc/xdg/autostart"
          ];
        };
    };
  };
}
