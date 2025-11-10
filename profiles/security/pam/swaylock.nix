{
  unify.modules."security/pam/swaylock" = {
    nixos = {
      meta = {
        tags = [ "desktop/niri" ];
      };

      module = _: {
        security.pam.services.swaylock = { };
      };
    };
  };
}
