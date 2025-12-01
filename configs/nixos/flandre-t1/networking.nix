{
  flake.unify.configs.nixos.flandre-t1 = {
    module =
      { ... }:
      {
        systemd.network = {
          enable = true;
          wait-online.anyInterface = true;
          networks = {
            "20-enp3s0" = {
              matchConfig.Name = "enp3s0";
              networkConfig = {
                DHCP = "ipv4";
                IPv6AcceptRA = true;
                IPv6PrivacyExtensions = true;
              };
              dhcpV4Config.RouteMetric = 1024;
              ipv6AcceptRAConfig.RouteMetric = 1024;
            };
          };
        };
      };
  };
}
