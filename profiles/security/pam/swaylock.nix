{
  flake.unify.modules."security/pam/swaylock" = {
    nixos = {
      meta = {
        tags = [ "desktop" ];
      };

      module =
        { ... }:
        {
          security.pam.services.swaylock = { };
        };
    };
  };
}
