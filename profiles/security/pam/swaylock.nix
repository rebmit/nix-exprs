{
  flake.unify.modules."security/pam/swaylock" = {
    nixos = {
      meta = {
        tags = [ "desktop/niri" ];
      };

      module =
        { ... }:
        {
          security.pam.services.swaylock = { };
        };
    };
  };
}
