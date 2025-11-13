# Portions of this file are sourced from
# https://github.com/nix-community/preservation/blob/93416f4614ad2dfed5b0dcf12f27e57d27a5ab11/tests/basic.nix (MIT License)
{ self, lib, ... }:
let
  inherit (lib.lists) filter;
  inherit (lib.strings) toJSON;
  inherit (lib.trivial) pipe;

  immutable = {
    imports = pipe { tags = [ "immutable" ]; } [
      (self.unify.lib.collectModulesForConfig "nixos")
      (map (n: self.modules.nixos.${n}))
    ];
  };
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks."modules/tests/preservation" = pkgs.testers.nixosTest {
        name = "preservation";

        nodes.machine =
          { pkgs, ... }:
          {
            imports = [
              self.nixosModules.preservation
              immutable
            ];

            preservation = {
              enable = true;
              persistentStoragePath = "/persist";
              directories = [
                {
                  directory = "/var/lib/nixos";
                  inInitrd = true;
                  user = "root";
                  group = "root";
                  mode = "0755";
                }
                {
                  directory = "/var/lib/service";
                  user = "rebmit";
                  group = "users";
                  mode = "0750";
                }
                "/var/log/journal"
              ];
              files = [
                {
                  file = "/var/lib/file";
                  inInitrd = true;
                }
              ];
              users = {
                rebmit = {
                  commonMountOptions = [ "x-bar" ];
                  directories = [
                    {
                      directory = "foo/bar/baz";
                      mountOptions = [ "x-baz" ];
                    }
                  ];
                  files = [ ".config/config" ];
                };
              };
              commonMountOptions = [ "x-foo" ];
            };

            testing.initrdBackdoor = true;

            boot.initrd.systemd.extraBin = {
              mountpoint = "${pkgs.util-linux}/bin/mountpoint";
            };

            networking.useNetworkd = true;

            users.users.rebmit = {
              isNormalUser = true;
              home = "/home/timber";
            };

            virtualisation = {
              memorySize = 2048;
              emptyDiskImages = [ 23 ];
              fileSystems."/persist" = {
                device = "/dev/vdb";
                fsType = "ext4";
                neededForBoot = true;
                autoFormat = true;
              };
            };
          };

        testScript =
          { nodes, ... }:
          let
            inherit (nodes.machine.passthru.preservation) getAllDirectories getAllFiles;

            rebmitHome = nodes.machine.users.users.rebmit.home;

            allFiles = getAllFiles nodes.machine.preservation;
            allDirectories = getAllDirectories nodes.machine.preservation;

            initrdFiles = filter (conf: conf.inInitrd) allFiles;
            initrdDirectories = filter (conf: conf.inInitrd) allDirectories;

            initrdJSON = toJSON (initrdDirectories ++ initrdFiles);
            allJSON = toJSON (allDirectories ++ allFiles);
          in
          # python
          ''
            import json

            initrd_files = json.loads('${initrdJSON}')
            all_files = json.loads('${allJSON}')

            def check_file(config, in_initrd=False):
              prefix = "/sysroot" if in_initrd else ""
              file_path = config.get("directory", config.get("file"))
              path = f"{prefix}{file_path}"

              # check that file is mounted
              machine.succeed(f"mountpoint {path}")

              # check permissions and ownership
              if all(config[k] != "-" for k in ("mode", "user", "group")):
                actual = machine.succeed(f"stat -c '0%a %U %G' {path} | tee /dev/stderr").strip()
                expected = "{} {} {}".format(config["mode"],config["user"],config["group"])
                t.assertEqual(actual, expected, "unexpected file attributes")

            machine.start(allow_reboot=True)
            machine.wait_for_unit("default.target")

            with subtest("Type, permissions and ownership in first boot initrd"):
              print(machine.succeed("cat /etc/preservation.conf"))
              for file in initrd_files:
                check_file(file, in_initrd=True)

            machine.switch_root()
            machine.wait_for_unit("default.target")

            with subtest("Machine ID file still mounted and now populated"):
              machine.succeed("test -s /etc/machine-id")

            with subtest("Type, permissions and ownership after first boot completed"):
              print(machine.succeed("cat /etc/preservation.conf"))
              for file in all_files:
                check_file(file)

            with subtest("Unpreserved intermediate user directories have correct permissions and ownership"):
                for path_segment in [ "foo", "foo/bar" ]:
                  actual = machine.succeed(f"stat -c '0%a %U %G' ${rebmitHome}/{path_segment} | tee /dev/stderr").strip()
                  expected = "0700 rebmit users"
                  t.assertEqual(actual, expected, "unexpected file attributes")

            with subtest("Unpreserved user home has same permissions and ownership on persistent prefix as actual user home"):
                actual = machine.succeed("stat -c '0%a %U %G' /persist${rebmitHome} | tee /dev/stderr").strip()
                expected = machine.succeed("stat -c '0%a %U %G' ${rebmitHome} | tee /dev/stderr").strip()
                t.assertEqual(actual, expected, "unexpected file attributes")

            with subtest("Files preserved across reboots"):
              # write something in one of the preserved files
              teststring = "foobarbaz"
              machine.succeed(f"echo -n '{teststring}' > ${rebmitHome}/foo/bar/baz/test")
              machine.succeed(f"echo -n '{teststring}' > /var/lib/file")

              # get current machine id
              machine_id = machine.succeed("cat /etc/machine-id")

              # reboot to initrd
              machine.reboot()
              machine.wait_for_unit("default.target")

              # preserved machine-id resides on /persist
              initrd_machine_id = machine.succeed("cat /sysroot/persist/var/lib/nixos/systemd/machine-id")
              t.assertEqual(initrd_machine_id, machine_id, "machine id changed")

              # check type, permissions and ownership before switch root
              for file in initrd_files:
                check_file(file, in_initrd=True)

              # proceed with boot
              machine.switch_root()
              machine.wait_for_unit("default.target")

              # check that machine-id remains unchanged in stage-2 after reboot
              machine.succeed("test -s /etc/machine-id")
              new_machine_id = machine.succeed("cat /etc/machine-id")
              t.assertEqual(new_machine_id, machine_id, "machine id changed")

              # check that state in file was also preserved
              machine.succeed("test -s ${rebmitHome}/foo/bar/baz/test")
              content = machine.succeed("cat ${rebmitHome}/foo/bar/baz/test")
              t.assertEqual(content, teststring, "unexpected file content")

              machine.succeed("test -s /var/lib/file")
              content = machine.succeed("cat /var/lib/file")
              t.assertEqual(content, teststring, "unexpected file content")

            with subtest("Type, permissions and ownership after reboot"):
              for file in all_files:
                check_file(file)

            with subtest("Custom (userspace) mount options are applied"):
              utab_entry = machine.succeed("grep TARGET=${rebmitHome}/foo/bar/baz /run/mount/utab")
              for opt in [ "x-foo", "x-bar", "x-baz" ]:
                t.assertIn(opt, utab_entry, "expected mount option not found")

            machine.shutdown()
          '';
      };
    };
}
