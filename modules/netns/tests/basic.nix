{
  config,
  lib,
  ...
}:
let
  inherit (lib.modules) mkForce;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks."netns/basic" = pkgs.nixosTest {
        name = "netns-basic";

        nodes.machine =
          { ... }:
          {
            imports = [
              config.flake.modules.nixos.netns
              config.flake.modules.nixos.immutable
            ];

            services.resolved.enable = true;
            systemd.network.enable = true;

            networking = {
              useNetworkd = true;
              hosts = {
                "127.0.0.1" = [ "one.one.one.one" ];
              };
            };

            netns = {
              entropy = {
                enable = false;
              };
              enthalpy = {
                confext."oldfile".text = "old-generation";
                sysctl = {
                  "net.ipv6.conf.all.forwarding" = 1;
                  "net.ipv6.conf.default.forwarding" = 1;
                };
                hosts = {
                  "1.1.1.1" = [ "one.one.one.one" ];
                };
              };
            };

            users.users.rebmit = {
              uid = 1000;
              isNormalUser = true;
            };

            specialisation.new-generation.configuration = {
              netns.enthalpy = {
                services.nscd.enable = false;
                confext = {
                  "oldfile".text = mkForce "new-generation";
                  "newfile".text = "new-generation";
                };
              };
            };
          };

        testScript =
          let
            path = "/run/current-system/sw/bin";
          in
          # python
          ''
            machine.start()
            machine.wait_for_unit("default.target")

            # common.nix
            with subtest("Network namespace creation and mounting"):
              machine.fail("systemctl status netns-entropy.service")
              machine.fail("mountpoint /run/netns/entropy")
              machine.fail("ip netns list | grep -w entropy")

              machine.succeed("systemctl status netns-enthalpy.service")
              machine.succeed("mountpoint /run/netns/enthalpy")
              machine.succeed("ip netns list | grep -w enthalpy")

            # common.nix
            with subtest("Network namespace switch"):
              machine.fail("test -e ${path}/netns-run-entropy")

              print(machine.succeed("cat ${path}/netns-run-init"))
              actual   = machine.succeed("netns-run-init ${path}/stat -Lc '%i' /proc/self/ns/net")
              expected = machine.succeed("stat -Lc '%i' /proc/1/ns/net")
              t.assertEqual(actual, expected, "Network namespace switch did not occur as expected")

              print(machine.succeed("cat ${path}/netns-run-enthalpy"))
              actual   = machine.succeed("netns-run-enthalpy ${path}/stat -Lc '%i' /proc/self/ns/net")
              expected = machine.succeed("stat -Lc '%i' /run/netns/enthalpy")
              t.assertEqual(actual, expected, "Network namespace switch did not occur as expected")

            # rootfs.nix
            with subtest("Initial /etc contents are in place"):
              machine.succeed("systemctl status netns-enthalpy-confext.service")

              actual   = machine.succeed("netns-run-enthalpy ${path}/cat /etc/oldfile")
              expected = "old-generation"
              t.assertEqual(expected, actual, "/etc/oldfile content mismatch")

              print(machine.succeed("netns-run-enthalpy ${path}/cat /etc/resolv.conf"))

            # nsswitch.nix
            with subtest("Network namespace specific /etc/nsswitch.conf is in place"):
              actual   = machine.succeed("netns-run-enthalpy ${path}/getent passwd rebmit")
              expected = "1000"
              t.assertIn(expected, actual, "passwd entries mismatch")

              actual = machine.succeed("cat /etc/nsswitch.conf")
              t.assertIn("resolve [!UNAVAIL=return]", actual)

              # unless we have finally switched to running resolved in the netns
              actual = machine.succeed("netns-run-enthalpy ${path}/cat /etc/nsswitch.conf")
              t.assertNotIn("resolve [!UNAVAIL=return]", actual)

            # sysctl
            with subtest("Network namespace specific kernel runtime parameters are set"):
              machine.succeed("systemctl status netns-enthalpy-sysctl.service")

              actual   = machine.succeed("sysctl net.ipv6.conf.all.forwarding")
              expected = "0"
              t.assertIn(expected, actual, "sysctl config mismatch")

              actual   = machine.succeed("netns-run-enthalpy ${path}/sysctl net.ipv6.conf.all.forwarding")
              expected = "1"
              t.assertIn(expected, actual, "sysctl config mismatch")

            # hosts
            with subtest("Hosts are in place"):
              print(machine.succeed("cat /etc/hosts"))
              print(machine.succeed("netns-run-enthalpy ${path}/cat /etc/hosts"))

              actual   = machine.succeed("getent hosts one.one.one.one")
              expected = "127.0.0.1"
              t.assertIn(expected, actual, "hosts mismatch")

              actual   = machine.succeed("netns-run-enthalpy ${path}/getent hosts one.one.one.one")
              expected = "1.1.1.1"
              t.assertIn(expected, actual, "hosts mismatch")

            # services/nscd.nix
            with subtest("Network namespaces have isolated nscd socket"):
              machine.succeed("systemctl status netns-enthalpy-nscd.service")

              enthalpy = machine.succeed("netns-run-enthalpy ${path}/stat -Lc '%i' /run/nscd/socket")
              init     = machine.succeed("stat -Lc '%i' /run/nscd/socket")
              t.assertNotEqual(enthalpy, init, "nscd is not isolated, dns leaks")

            machine.succeed("/run/current-system/specialisation/new-generation/bin/switch-to-configuration switch")

            # rootfs.nix
            with subtest("Updated /etc contents are applied after switch"):
              actual   = machine.succeed("netns-run-enthalpy ${path}/cat /etc/oldfile")
              expected = "new-generation"
              t.assertEqual(expected, actual, "/etc/oldfile content mismatch after switch")

              actual   = machine.succeed("netns-run-enthalpy ${path}/cat /etc/newfile")
              expected = "new-generation"
              t.assertEqual(expected, actual, "/etc/newfile content mismatch after switch")

            # services/nscd.nix
            with subtest("Network namespaces have isolated nscd socket"):
              machine.fail("systemctl status netns-enthalpy-nscd.service")

              enthalpy = machine.fail("netns-run-enthalpy ${path}/test -e /run/nscd/socket")
              init     = machine.succeed("stat -Lc '%i' /run/nscd/socket")

            machine.shutdown()
          '';
      };
    };
}
