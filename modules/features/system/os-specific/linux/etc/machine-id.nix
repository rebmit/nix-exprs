{ unify, lib, ... }:
let
  inherit (lib.attrsets) setAttrByPath;
  inherit (lib.meta) getExe;
in
{
  unify.features.system._.os-specific._.linux._.etc._.machine-id =
    { ... }:
    {
      requires = [ "features/system/os-specific/linux/initrd/systemd" ];

      nixos =
        { pkgs, ... }:
        {
          environment.etc."machine-id" = {
            source = "/var/lib/nixos/systemd/machine-id";
            mode = "direct-symlink";
          };

          boot.initrd.systemd.tmpfiles.settings.machine-id = {
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
        };
    };

  checks =
    { pkgs, ... }:
    let
      provider = unify.features.system._.os-specific._.linux._.etc._.machine-id;

      mkTest =
        {
          name,
          extraRequires ? [ ],
        }:
        pkgs.testers.runNixOSTest {
          name = "${provider.name}/${name}";

          nodes.machine =
            { ... }:
            {
              imports = [
                (unify.lib.collectModules {
                  class = "nixos";
                  requires = [
                    provider.name
                    "features/system/os-specific/linux/kernel/latest"
                  ]
                  ++ extraRequires;
                })
              ];

              networking.useNetworkd = true;

              virtualisation = {
                diskImage = null;
                emptyDiskImages = [ 512 ];
                fileSystems."/var" = {
                  device = "/dev/vda";
                  fsType = "ext4";
                  neededForBoot = true;
                  autoFormat = true;
                };
              };
            };

          testScript =
            # python
            ''
              machine.start(allow_reboot=True)
              machine.wait_for_unit("default.target")

              machine.succeed("findmnt --kernel --types tmpfs /")

              with subtest("Initial boot meets ConditionFirstBoot"):
                machine.require_unit_state("first-boot-complete.target", "active")
                machine.require_unit_state("systemd-machine-id-commit.service", "active")

              with subtest("/etc/machine-id is preserved across reboots"):
                machine_id = machine.succeed("cat /etc/machine-id")

                machine.reboot()
                machine.wait_for_unit("default.target")

                machine.succeed("test -s /etc/machine-id")
                new_machine_id = machine.succeed("cat /etc/machine-id")
                t.assertEqual(new_machine_id, machine_id, "machine id changed")

              with subtest("Second boot does not meet ConditionFirstBoot"):
                machine.require_unit_state("first-boot-complete.target", "inactive")
                machine.require_unit_state("systemd-machine-id-commit.service", "inactive")

              machine.shutdown()
            '';
        };
    in
    {
      tests = setAttrByPath provider.path {
        basic = mkTest {
          name = "basic";
        };

        etc-overlay = mkTest {
          name = "etc-overlay";
          extraRequires = [ "features/system/os-specific/linux/etc/overlay" ];
        };
      };
    };
}
