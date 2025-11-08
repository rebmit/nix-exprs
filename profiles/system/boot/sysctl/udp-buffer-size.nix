{
  unify.modules."system/boot/sysctl/udp-buffer-size" = {
    nixos = {
      meta = {
        tags = [ "network" ];
      };

      module = _: {
        # https://github.com/quic-go/quic-go/wiki/UDP-Buffer-Sizes
        boot.kernel.sysctl = {
          "net.core.rmem_max" = 7500000;
          "net.core.wmem_max" = 7500000;
        };
      };
    };
  };
}
