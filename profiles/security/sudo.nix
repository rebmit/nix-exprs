{
  flake.unify.modules."security/sudo" = {
    nixos = {
      meta = {
        conflicts = [ "security/sudo-rs" ];
      };

      module =
        { ... }:
        {
          security.sudo = {
            execWheelOnly = true;
            wheelNeedsPassword = true;
            extraConfig = ''
              Defaults lecture="never"
            '';
          };
        };
    };
  };
}
