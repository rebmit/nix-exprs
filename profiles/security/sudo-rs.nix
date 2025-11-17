{
  flake.unify.modules."security/sudo-rs" = {
    nixos = {
      meta = {
        conflicts = [ "security/sudo" ];
      };

      module =
        { ... }:
        {
          security.sudo.enable = false;

          security.sudo-rs = {
            enable = true;
            execWheelOnly = true;
            wheelNeedsPassword = true;
          };
        };
    };
  };
}
