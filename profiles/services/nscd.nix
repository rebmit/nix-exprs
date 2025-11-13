{ self, lib, ... }:
let
  inherit (lib.modules) mkForce;
  inherit (self.lib.misc) mkHardenedService;
in
{
  flake.unify.modules."services/nscd" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
      };

      module =
        { ... }:
        {
          services.nscd = {
            enable = true;
            enableNsncd = true;
          };

          systemd.services.nscd = mkHardenedService { serviceConfig.ProtectHome = mkForce true; };
        };
    };
  };
}
