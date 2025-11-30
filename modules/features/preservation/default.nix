{ unify, ... }:
{
  flake.nixosModules.preservation = unify.lib.collectModules {
    class = "nixos";
    providerNames = [ unify.features.preservation.name ];
  };
}
