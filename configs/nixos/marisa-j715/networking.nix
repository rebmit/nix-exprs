{
  flake.unify.configs.nixos.marisa-j715 = {
    module =
      { ... }:
      {
        systemd.network = {
          enable = true;
          wait-online.anyInterface = true;
          networks = {
            "20-enp0s1" = {
              matchConfig.Name = "enp0s1";
              networkConfig = {
                DHCP = "yes";
                IPv6AcceptRA = true;
                IPv6PrivacyExtensions = true;
              };
              dhcpV4Config.RouteMetric = 1024;
              dhcpV6Config.RouteMetric = 1024;
              ipv6AcceptRAConfig.RouteMetric = 1024;
            };
          };
        };
      };
  };
}
