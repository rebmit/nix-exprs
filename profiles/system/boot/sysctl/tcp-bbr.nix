{
  flake.unify.modules."system/boot/sysctl/tcp-bbr" = {
    nixos = {
      meta = {
        tags = [ "network" ];
      };

      module = _: {
        boot.kernel.sysctl = {
          "net.core.default_qdisc" = "fq";
          "net.ipv4.tcp_congestion_control" = "bbr";
        };
      };
    };
  };
}
