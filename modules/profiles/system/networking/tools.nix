{
  unify.profiles.system._.networking._.tools =
    { ... }:
    {
      nixos =
        { pkgs, ... }:
        {
          programs.mtr.enable = true;

          environment.systemPackages = with pkgs; [
            # keep-sorted start
            dnsutils
            ethtool
            iperf3
            netcat
            nmap
            socat
            tcpdump
            # keep-sorted end
          ];
        };

      darwin =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            # keep-sorted start
            dnsutils
            iperf3
            mtr
            netcat
            nmap
            socat
            tcpdump
            # keep-sorted end
          ];
        };
    };
}
