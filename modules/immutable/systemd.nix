{ lib, ... }:
let
  inherit (lib.modules) mkMerge;
  inherit (lib.meta) getExe;
in
{
  flake.modules.nixos.immutable = mkMerge [
    # initrd
    (
      { config, ... }:
      {
        assertions = [
          {
            assertion = !config.boot.isContainer;
            message = ''
              `config.boot.initrd.systemd.enable` and `config.boot.isContainer`
              cannot be enabled at the same time.
            '';
          }
        ];

        boot.initrd.systemd.enable = true;
      }
    )

    # machine-id
    (
      { pkgs, ... }:
      {
        environment.etc."machine-id" = {
          source = "/var/lib/nixos/systemd/machine-id";
          mode = "direct-symlink";
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

        boot.initrd.systemd.tmpfiles.settings.immutable = {
          "/sysroot/var/lib/nixos/systemd".d = {
            user = "root";
            group = "root";
            mode = "0755";
          };
        };
      }
    )
  ];
}
