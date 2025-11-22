{
  flake.unify.modules."tags/features/network" = {
    nixos = {
      meta = {
        requires = [
          # keep-sorted start
          "programs/collections/network"
          "services/networkd"
          "services/nftables"
          "services/resolved"
          "services/vnstat"
          "system/boot/sysctl/tcp-bbr"
          "system/boot/sysctl/udp-buffer-size"
          # keep-sorted end
        ];
      };
    };

    homeManager = {
      meta = {
        requires = [ ];
      };
    };
  };
}
