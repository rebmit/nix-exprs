{
  flake.unify.modules."security/sudo-rs" = {
    nixos = {
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
