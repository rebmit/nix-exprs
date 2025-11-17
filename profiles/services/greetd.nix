{ lib, ... }:
let
  inherit (lib.meta) getExe;
in
{
  flake.unify.modules."services/greetd" = {
    nixos = {
      module =
        { pkgs, ... }:
        {
          services.greetd = {
            enable = true;
            useTextGreeter = true;
            settings = {
              default_session.command = "${getExe pkgs.tuigreet} --cmd wayland-session";
            };
          };

          services.graphical-desktop.enable = false;
        };
    };
  };
}
