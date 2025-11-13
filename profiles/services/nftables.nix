{
  flake.unify.modules."services/nftables" = {
    nixos = {
      meta = {
        tags = [ "network" ];
      };

      module =
        { ... }:
        {
          networking.nftables.enable = true;
        };
    };
  };
}
