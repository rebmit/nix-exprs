{
  unify.profiles.networking._.defaults =
    { ... }:
    {
      nixos =
        { ... }:
        {
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
