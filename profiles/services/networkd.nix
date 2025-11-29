{
  flake.unify.modules."services/networkd" = {
    nixos = {
      module =
        { ... }:
        {
          networking = {
            useNetworkd = true;
            useDHCP = false;
          };

          systemd.network.enable = true;
        };
    };
  };
}
