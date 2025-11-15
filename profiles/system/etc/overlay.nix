{ lib, ... }:
let
  inherit (lib.modules) mkOptionDefault;
in
{
  flake.unify.modules."system/etc/overlay" = {
    nixos = {
      meta = {
        tags = [ "immutable" ];
        requires = [
          "system/boot/initrd/systemd"
          "system/etc/machine-id"
          "system/userborn"
        ];
      };

      module =
        { ... }:
        {
          system.etc.overlay = {
            enable = true;
            mutable = false;
          };

          virtualisation.vmVariant = {
            environment.etc."resolv.conf" = mkOptionDefault {
              text = ''
                nameserver 2620:fe::fe
                nameserver 9.9.9.9
              '';
            };
          };
        };
    };
  };
}
