{ lib, ... }:
let
  inherit (lib.modules) mkOptionDefault;
  inherit (lib.meta) getExe;
in
{
  flake.unify.modules."system/etc/overlay" = {
    nixos = {
      meta = {
        tags = [ "immutable" ];
        requires = [ "system/boot/initrd/systemd" ];
      };

      module =
        { pkgs, ... }:
        {
          system.etc.overlay = {
            enable = true;
            mutable = false;
          };

          environment.etc."machine-id" = {
            source = "/var/lib/nixos/systemd/machine-id";
            mode = "direct-symlink";
          };

          boot.initrd.systemd.tmpfiles.settings.immutable = {
            "/sysroot/var/lib/nixos/systemd/machine-id".f = {
              user = "root";
              group = "root";
              mode = "0444";
              argument = "uninitialized";
            };
          };

          systemd.services.systemd-machine-id-commit = {
            unitConfig.ConditionPathIsMountPoint = [
              ""
              "/var/lib/nixos/systemd/machine-id"
            ];
            serviceConfig.ExecStart = [
              ""
              (getExe (
                pkgs.writeShellApplication {
                  name = "machine-id-commit";
                  runtimeInputs = with pkgs; [
                    bash
                    coreutils
                    util-linux
                  ];
                  text = ''
                    MACHINE_ID=$(/run/current-system/systemd/bin/systemd-id128 machine-id)
                    export MACHINE_ID
                    unshare --mount --propagation slave bash ${pkgs.writeShellScript "machine-id-commit" ''
                      umount /var/lib/nixos/systemd/machine-id
                      printf "$MACHINE_ID" > /var/lib/nixos/systemd/machine-id
                    ''}
                    umount /var/lib/nixos/systemd/machine-id
                  '';
                }
              ))
            ];
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
