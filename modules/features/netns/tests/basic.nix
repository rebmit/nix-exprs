{ self, lib, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks."features/netns/basic" = pkgs.testers.nixosTest {
        name = "netns-basic";

        nodes.machine =
          { ... }:
          {
            imports = [
              self.nixosModules.netns
              self.modules.nixos.immutable
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
                services.resolved.enable = true;
                confext."oldfile".text = "old-generation";
                sysctl = {
                  "net.ipv6.conf.all.forwarding" = 1;
                  "net.ipv6.conf.default.forwarding" = 1;
                };
                hosts = {
                  "1.1.1.1" = [ "one.one.one.one" ];
                  "2001:db8::1" = [ "test.internal" ];
                  "192.168.0.1" = [ "test.internal" ];
                };
                getaddrinfo = {
                  reload = true;
                  label = {
                    "::1/128" = 0;
                    "::/0" = 1;
                    "2002::/16" = 2;
                    "::/96" = 3;
                    "::ffff:0:0/96" = 4;
                  };
                  precedence = {
                    "::1/128" = 50;
                    "::/0" = 40;
                    "2002::/16" = 30;
                    "::/96" = 20;
                    "::ffff:0:0/96" = 10;
                  };
                };
              };
            };

            users.users.rebmit = {
              uid = 1000;
              isNormalUser = true;
            };

            specialisation.new-generation.configuration = {
              systemd.network = {
                enable = true;
                networks = {
                  "20-enthalpy" = {
                    matchConfig.Name = "enthalpy";
                  };
                };
              };

              netns.enthalpy = {
                services.resolved.enable = mkForce false;
                services.nscd.enable = false;
                confext = {
                  "oldfile".text = mkForce "new-generation";
                  "newfile".text = "new-generation";
                };
                getaddrinfo = {
                  precedence = {
                    "::ffff:0:0/96" = mkForce 100;
                  };
                };
                netdevs.host = {
                  kind = "veth";
                  mtu = 1400;
                  address = "02:00:00:00:00:01";
                  extraArgs.peer = {
                    name = "enthalpy";
                    mtu = 1400;
                    address = "02:00:00:00:00:02";
                    netns = "/proc/1/ns/net";
                  };
                };
                services.networkd = {
                  enable = true;
                  netdevs = {
                    "20-enthalpy" = {
                      netdevConfig = {
                        Kind = "dummy";
                        Name = "enthalpy";
                      };
                    };
                  };
                  networks = {
                    "20-host" = {
                      matchConfig.Name = "host";
                    };
                    "20-enthalpy" = {
                      matchConfig.Name = "enthalpy";
                      linkConfig.MTUBytes = 9000;
                      networkConfig = {
                        Address = [
                          "192.168.0.1/24"
                          "fdab:cdef::1/64"
                        ];
                      };
                    };
                  };
                };
                nftables = {
                  enable = true;
                  tables.nat = {
                    family = "inet";
                    content = ''
                      chain postrouting {
                        type nat hook postrouting priority srcnat; policy accept;
                        oifname enthalpy counter masquerade
                      }
                    '';
                  };
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

            # confext.nix
            with subtest("Initial /etc contents are in place"):
              machine.succeed("systemctl status netns-enthalpy-confext.service")

              actual   = machine.succeed("netns-run-enthalpy ${path}/cat /etc/oldfile")
              expected = "old-generation"
              t.assertEqual(expected, actual, "/etc/oldfile content mismatch")

              print(machine.succeed("netns-run-enthalpy ${path}/cat /etc/resolv.conf"))

            # config/nsswitch.nix
            with subtest("Network namespace specific /etc/nsswitch.conf is in place"):
              actual   = machine.succeed("netns-run-enthalpy ${path}/getent passwd rebmit")
              expected = "1000"
              t.assertIn(expected, actual, "passwd entries mismatch")

            # config/sysctl.nix
            with subtest("Network namespace specific kernel runtime parameters are set"):
              machine.succeed("systemctl status netns-enthalpy-sysctl.service")

              actual   = machine.succeed("sysctl net.ipv6.conf.all.forwarding")
              expected = "0"
              t.assertIn(expected, actual, "sysctl config mismatch")

              actual   = machine.succeed("netns-run-enthalpy ${path}/sysctl net.ipv6.conf.all.forwarding")
              expected = "1"
              t.assertIn(expected, actual, "sysctl config mismatch")

            # config/hosts.nix
            with subtest("Hosts are in place"):
              print(machine.succeed("cat /etc/hosts"))
              print(machine.succeed("netns-run-enthalpy ${path}/cat /etc/hosts"))

              actual   = machine.succeed("getent hosts one.one.one.one")
              expected = "127.0.0.1"
              t.assertIn(expected, actual, "hosts mismatch")

              actual   = machine.succeed("netns-run-enthalpy ${path}/getent hosts one.one.one.one")
              expected = "1.1.1.1"
              t.assertIn(expected, actual, "hosts mismatch")

            # config/getaddrinfo.nix
            with subtest("Network namespace specific /etc/gai.conf is in place"):
              print(machine.succeed("netns-run-enthalpy ${path}/cat /etc/gai.conf"))
              actual   = machine.succeed("netns-run-enthalpy ${path}/getent ahosts test.internal").splitlines()[0].split()[0]
              expected = "2001:db8::1"
              t.assertIn(expected, actual, "getaddrinfo result mismatch")

            # config/tmpfiles.nix
            with subtest("systemd-tmpfiles works"):
              print(machine.succeed("systemctl status netns-enthalpy-tmpfiles.service"))

              actual   = machine.succeed("netns-run-enthalpy ${path}/stat -c '%a' /tmp")
              expected = "1777"
              t.assertIn(expected, actual, "/tmp sticky bits mismatch")

            # services/nscd.nix
            with subtest("Network namespaces have isolated nscd socket"):
              machine.succeed("systemctl status netns-enthalpy-nscd.service")

              enthalpy = machine.succeed("netns-run-enthalpy ${path}/stat -Lc '%i' /run/nscd/socket")
              init     = machine.succeed("stat -Lc '%i' /run/nscd/socket")
              t.assertNotEqual(enthalpy, init, "nscd is not isolated, dns leaks")

              machine.succeed("netns-run-enthalpy ${path}/getent passwd netns-enthalpy-nscd")

            # services/resolved.nix
            with subtest("systemd-resolved is active"):
              machine.succeed("systemctl status netns-enthalpy-resolved.service")

            machine.succeed("/run/current-system/specialisation/new-generation/bin/switch-to-configuration switch")

            # config/confext.nix
            with subtest("Updated /etc contents are applied after switch"):
              actual   = machine.succeed("netns-run-enthalpy ${path}/cat /etc/oldfile")
              expected = "new-generation"
              t.assertEqual(expected, actual, "/etc/oldfile content mismatch after switch")

              actual   = machine.succeed("netns-run-enthalpy ${path}/cat /etc/newfile")
              expected = "new-generation"
              t.assertEqual(expected, actual, "/etc/newfile content mismatch after switch")

            # config/nftables.nix
            with subtest("nftables is properly configured"):
              actual   = machine.succeed("netns-run-enthalpy ${path}/nft list ruleset")
              expected = "masquerade"
              t.assertIn(expected, actual, "nftables not configured as expected")

            # config/netdevs.nix
            with subtest("Scripted netdevs configuration works"):
              machine.succeed("systemctl status netns-enthalpy-netdev-host.service")

              print(machine.succeed("netns-run-enthalpy ${path}/ping -c 4 ff02::1%host"))

            # config/getaddrinfo.nix
            with subtest("Network namespace specific /etc/gai.conf is in place"):
              print(machine.succeed("netns-run-enthalpy ${path}/cat /etc/gai.conf"))
              actual   = machine.succeed("netns-run-enthalpy ${path}/getent ahosts test.internal").splitlines()[0].split()[0]
              expected = "192.168.0.1"
              t.assertIn(expected, actual, "getaddrinfo result mismatch")

            # services/nscd.nix
            with subtest("Network namespaces have isolated nscd socket"):
              machine.fail("systemctl status netns-enthalpy-nscd.service")

              enthalpy = machine.fail("netns-run-enthalpy ${path}/test -e /run/nscd/socket")
              init     = machine.succeed("stat -Lc '%i' /run/nscd/socket")

            # services/networkd.nix
            with subtest("systemd-networkd is active"):
              machine.succeed("systemctl status netns-enthalpy-networkd.service")

            # services/networkd.nix
            with subtest("enthalpy interface is properly configured"):
              actual   = machine.succeed("netns-run-enthalpy ${path}/ip -4 a show dev enthalpy")
              expected = "192.168.0.1/24"
              t.assertIn(expected, actual, "ipv4 not configured as expected")

              actual   = machine.succeed("netns-run-enthalpy ${path}/ip -6 a show dev enthalpy")
              expected = "fdab:cdef::1/64"
              t.assertIn(expected, actual, "ipv6 not configured as expected")

            machine.shutdown()
          '';
      };
    };
}
