{ lib, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.meta) getExe;
in
{
  flake.unify.modules."system/etc/machine-id" = {
    nixos = {
      module =
        { config, pkgs, ... }:
        {
          environment.etc."machine-id" = {
            source = "/var/lib/nixos/systemd/machine-id";
            mode = "direct-symlink";
          };

          boot.initrd.systemd.tmpfiles.settings.immutable = mkIf config.boot.initrd.systemd.enable {
            "/sysroot/var/lib/nixos/systemd/machine-id".f = {
              user = "root";
              group = "root";
              mode = "0444";
              argument = "uninitialized";
            };
          };

          system.activationScripts.tmpfiles = mkIf (!config.boot.initrd.systemd.enable) {
            text = ''
              mkdir -p /var/lib/nixos/systemd
              if [ ! -e /var/lib/nixos/systemd/machine-id ]; then
                echo "uninitialized" > /var/lib/nixos/systemd/machine-id
                chown -v root:root     /var/lib/nixos/systemd/machine-id
                chmod -v 0444          /var/lib/nixos/systemd/machine-id
              fi
            '';
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
        };
    };
  };
}
