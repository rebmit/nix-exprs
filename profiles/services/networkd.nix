{ lib, ... }:
let
  inherit (lib.modules) mkVMOverride;
in
{
  flake.unify.modules."services/networkd" = {
    nixos = {
      module =
        { ... }:
        {
          networking = {
            useNetworkd = true;
            useDHCP = false;
          };

          systemd.network.enable = true;

          virtualisation.vmVariant = {
            systemd.network.networks."00-eth0" = mkVMOverride {
              name = "eth0";
              DHCP = "yes";
            };
          };
        };
    };
  };
}
