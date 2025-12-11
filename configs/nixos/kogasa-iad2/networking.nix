{ meta, ... }:
{
  flake.unify.configs.nixos.kogasa-iad2 = {
    module =
      { unify, ... }:
      {
        systemd.network = {
          enable = true;
          wait-online.anyInterface = true;
          networks = {
            "20-enp0s3" = {
              matchConfig.Name = "enp0s3";
              networkConfig = {
                DHCP = "ipv4";
                IPv6AcceptRA = false;
                IPv6PrivacyExtensions = false;
              };
              addresses = map (addr: {
                Address = "${addr}/64";
                RouteMetric = 1024;
              }) meta.data.hosts.${unify.name}.endpoints_v6;
              routes = [
                {
                  Gateway = "fe80::1";
                  Metric = 1024;
                }
              ];
              dhcpV4Config.RouteMetric = 1024;
              ipv6AcceptRAConfig.RouteMetric = 1024;
            };
          };
        };
      };
  };
}
