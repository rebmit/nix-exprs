{ self, lib, ... }:
let
  inherit (lib.trivial) pipe;

  immutable = {
    imports = pipe { includes = [ "tags/immutable" ]; } [
      (self.unify.lib.collectModulesForConfig "nixos")
      (map (n: self.modules.nixos.${n}))
    ];
  };
in
{
  perSystem =
    { pkgs, ... }:
    let
      common = {
        imports = [
          self.nixosModules.enthalpy
          self.nixosModules.netns
          immutable
        ];

        services.resolved.enable = true;
        systemd.network.enable = true;
        networking.useNetworkd = true;

        networking.firewall.enable = false;

        boot.kernelPackages = pkgs.linuxPackages_latest;

        services.enthalpy = {
          enable = true;
          network = "fd97:f72e:270c::/48";
          ipsec = {
            organization = "test";
            endpoints = [
              {
                serialNumber = "0";
                addressFamily = "ip4";
              }
              {
                serialNumber = "1";
                addressFamily = "ip6";
              }
            ];
            interfaces = [ "eth1" ];
            privateKeyPath = "${pkgs.writeText "private-key" ''
              -----BEGIN PRIVATE KEY-----
              MC4CAQAwBQYDK2VwBCIEIPntkfGC5R74FHJ1abA6AZSg0DrlxbahcjJAMChDR+ON
              -----END PRIVATE KEY-----
            ''}";
          };
        };

        system.activationScripts.setup-registry = ''
          mkdir -pv /var/lib/ranet

          cp -v "${
            (pkgs.formats.json { }).generate "registry.json" [
              {
                public_key = "-----BEGIN PUBLIC KEY-----\nMCowBQYDK2VwAyEAcK433xJKBLOZTGJM1RRz7p+/8Gtw6jm8HT+Zw2OYo2c=\n-----END PUBLIC KEY-----";
                organization = "test";
                nodes = [
                  {
                    common_name = "peer1";
                    endpoints = [
                      {
                        serial_number = "0";
                        address_family = "ip4";
                        address = "192.168.0.1";
                        port = 14000;
                      }
                      {
                        serial_number = "1";
                        address_family = "ip6";
                        address = "fd00::1";
                        port = 14000;
                      }
                    ];
                  }
                  {
                    common_name = "peer2";
                    endpoints = [
                      {
                        serial_number = "0";
                        address_family = "ip4";
                        address = "192.168.0.2";
                        port = 14000;
                      }
                      {
                        serial_number = "1";
                        address_family = "ip6";
                        address = "fd00::2";
                        port = 14000;
                      }
                    ];
                  }
                ];
              }
            ]
          }" /var/lib/ranet/registry.json
        '';
      };
    in
    {
      checks."modules/tests/enthalpy" = pkgs.testers.nixosTest {
        name = "enthalpy";

        nodes.peer1 =
          { ... }:
          {
            imports = [ common ];

            services.enthalpy = {
              prefix = "fd97:f72e:270c:1010::/60";
              srv6.enable = true;
              exit.enable = true;
            };

            networking.hostName = "peer1";

            networking.interfaces.eth0 = {
              ipv4.addresses = [
                {
                  address = "1.1.1.1"; # for local testing only; RFC 6052 requires a public IPv4 address here
                  prefixLength = 32;
                }
              ];
            };

            networking.interfaces.eth1 = {
              ipv4.addresses = [
                {
                  address = "192.168.0.1";
                  prefixLength = 24;
                }
              ];
              ipv6.addresses = [
                {
                  address = "fd00::1";
                  prefixLength = 64;
                }
              ];
            };
          };

        nodes.peer2 =
          { ... }:
          {
            imports = [ common ];

            services.enthalpy = {
              prefix = "fd97:f72e:270c:1020::/60";
              clat = {
                enable = true;
                segment = [ "fd97:f72e:270c:1016::2" ];
              };
            };

            networking.hostName = "peer2";

            networking.interfaces.eth1 = {
              ipv4.addresses = [
                {
                  address = "192.168.0.2";
                  prefixLength = 24;
                }
              ];
              ipv6.addresses = [
                {
                  address = "fd00::2";
                  prefixLength = 64;
                }
              ];
            };
          };

        testScript =
          let
            path = "/run/current-system/sw/bin";
          in
          # python
          ''
            import json

            start_all()

            peer1.wait_for_unit("strongswan-swanctl.service")
            peer2.wait_for_unit("strongswan-swanctl.service")

            with subtest("Link-scope network connectivity test"):
              peer1.wait_until_succeeds("test $(netns-run-enthalpy ${path}/ip a | grep -c enta) -eq 2", timeout=10)
              peer2.wait_until_succeeds("test $(netns-run-enthalpy ${path}/ip a | grep -c enta) -eq 2", timeout=10)

              print(peer1.succeed("swanctl --list-sas"))
              print(peer2.succeed("swanctl --list-sas"))

              output       = peer1.succeed("netns-run-enthalpy ${path}/ip -j -6 addr show")
              ifaces_peer1 = [iface["ifname"] for iface in json.loads(output) if "enta" in iface["ifname"]]
              assert len(ifaces_peer1) == 2, "peer1 does not have exactly 2 enta interfaces"

              output       = peer2.succeed("netns-run-enthalpy ${path}/ip -j -6 addr show")
              ifaces_peer2 = [iface["ifname"] for iface in json.loads(output) if "enta" in iface["ifname"]]
              assert len(ifaces_peer2) == 2, "peer2 does not have exactly 2 enta interfaces"

              print(peer1.succeed(f"netns-run-enthalpy ${path}/ping -c 4 ff02::1%{ifaces_peer1[0]}"))
              print(peer1.succeed(f"netns-run-enthalpy ${path}/ping -c 4 ff02::1%{ifaces_peer1[1]}"))

              print(peer2.succeed(f"netns-run-enthalpy ${path}/ping -c 4 ff02::1%{ifaces_peer2[0]}"))
              print(peer2.succeed(f"netns-run-enthalpy ${path}/ping -c 4 ff02::1%{ifaces_peer2[1]}"))

            peer1.wait_for_unit("netns-enthalpy-bird.service")
            peer2.wait_for_unit("netns-enthalpy-bird.service")

            with subtest("Site-scope network connectivity test"):
              peer1.wait_until_succeeds("netns-run-enthalpy ${path}/ip -6 r | grep -q fd97:f72e:270c:1020::/60", timeout=10)
              peer2.wait_until_succeeds("netns-run-enthalpy ${path}/ip -6 r | grep -q fd97:f72e:270c:1010::/60", timeout=10)

              print(peer1.succeed("netns-run-enthalpy ${path}/ping -c 4 fd97:f72e:270c:1020::1"))
              print(peer2.succeed("netns-run-enthalpy ${path}/ping -c 4 fd97:f72e:270c:1010::1"))

              print(peer1.succeed("netns-run-enthalpy ${path}/ping -c 4 fd00::1"))
              print(peer2.succeed("netns-run-enthalpy ${path}/ping -c 4 fd00::1"))

            with subtest("464XLAT over SRv6 connectivity test"):
              peer1.succeed("systemctl status enthalpy-srv6.service")
              peer1.succeed("systemctl status plat.service")

              print(peer1.succeed("netns-run-enthalpy ${path}/ip -6 r show table localsid"))
              print(peer1.succeed("netns-run-enthalpy ${path}/ping -c 4 64:ff9b::1.1.1.1"))

              peer2.succeed("systemctl status enthalpy-clat.service")

              print(peer2.succeed("netns-run-enthalpy ${path}/ip -6 r show table main"))
              print(peer2.succeed("netns-run-enthalpy ${path}/ip -4 r show table main"))

              print(peer2.succeed("netns-run-enthalpy ${path}/ping -c 4 64:ff9b::1.1.1.1"))
              print(peer2.succeed("netns-run-enthalpy ${path}/ping -c 4 1.1.1.1"))

            peer1.shutdown()
            peer2.shutdown()
          '';
      };
    };
}
