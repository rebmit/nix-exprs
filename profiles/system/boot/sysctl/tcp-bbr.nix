{
  flake.unify.modules."system/boot/sysctl/tcp-bbr" = {
    nixos = {
      module =
        { ... }:
        {
          boot.kernel.sysctl = {
            "net.core.default_qdisc" = "fq";
            "net.ipv4.tcp_congestion_control" = "bbr";
          };
        };
    };
  };
}
