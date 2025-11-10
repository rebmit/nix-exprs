{
  flake.unify.modules."services/nftables" = {
    nixos = {
      meta = {
        tags = [ "network" ];
      };

      module = _: {
        networking.nftables.enable = true;
      };
    };
  };
}
