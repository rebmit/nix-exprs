{
  flake.unify.modules."programs/collections/network" = {
    nixos = {
      module =
        { pkgs, ... }:
        {
          programs.mtr.enable = true;

          environment.systemPackages = with pkgs; [
            # keep-sorted start
            aria2
            ethtool
            iperf3
            knot-dns
            netcat
            nmap
            socat
            tcpdump
            whois
            # keep-sorted end
          ];
        };
    };
  };
}
