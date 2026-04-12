{
  unify.features.system._.networking._.defaults =
    { ... }:
    {
      nixos =
        { ... }:
        {
          boot.kernel.sysctl = {
            "net.core.default_qdisc" = "fq";
            "net.ipv4.tcp_congestion_control" = "bbr";
            "net.core.rmem_max" = 7500000;
            "net.core.wmem_max" = 7500000;
          };

          networking = {
            nftables.enable = true;
            useNetworkd = true;
            useDHCP = false;
          };

          systemd.network.enable = true;

          services.resolved.enable = true;
        };
    };
}
