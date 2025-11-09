{ self, lib, ... }:
let
  inherit (lib.modules) mkForce;
  inherit (self.lib.misc) mkHardenedService;
in
{
  unify.modules."services/nscd" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
      };

      module = _: {
        services.nscd = {
          enable = true;
          enableNsncd = true;
        };

        systemd.services.nscd = mkHardenedService { serviceConfig.ProtectHome = mkForce true; };
      };
    };
  };
}
