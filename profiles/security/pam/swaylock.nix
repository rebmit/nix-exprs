{
  flake.unify.modules."security/pam/swaylock" = {
    nixos = {
      module =
        { ... }:
        {
          security.pam.services.swaylock = { };
        };
    };
  };
}
