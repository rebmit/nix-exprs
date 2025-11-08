{
  unify.modules."services/networkd" = {
    nixos = {
      meta = {
        tags = [ "network" ];
      };

      module = _: {
        networking = {
          useNetworkd = true;
          useDHCP = false;
        };

        systemd.network.enable = true;
      };
    };
  };
}
