{
  flake.unify.modules."services/nftables" = {
    nixos = {
      module =
        { ... }:
        {
          networking.nftables.enable = true;
        };
    };
  };
}
