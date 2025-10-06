{
  config,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    {
      checks."netns/networkd" = pkgs.nixosTest {
        name = "netns-networkd";

        nodes.machine =
          { ... }:
          {
            imports = [
              config.flake.modules.nixos.netns
              config.flake.modules.nixos.immutable
            ];

            services.resolved.enable = true;
            systemd.network.enable = true;
            networking.useNetworkd = true;

            netns.enthalpy = {
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

            with subtest("systemd-networkd is active"):
              machine.succeed("systemctl status netns-enthalpy-networkd.service")

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
