{
  flake.unify.configs.nixos.marisa-7d76 = {
    meta = {
      tags = [ "network" ];
    };

    module = _: {
      systemd.network = {
        enable = true;
        wait-online.anyInterface = true;
        networks = {
          "30-enp14s0" = {
            matchConfig.Name = "enp14s0";
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
