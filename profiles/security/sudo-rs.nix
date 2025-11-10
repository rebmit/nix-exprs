{
  flake.unify.modules."security/sudo-rs" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
        conflicts = [ "security/sudo" ];
      };

      module = _: {
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
