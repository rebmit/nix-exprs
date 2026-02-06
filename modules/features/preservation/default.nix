{ unify, ... }:
{
  flake.nixosModules.preservation = unify.lib.collectModules {
    class = "nixos";
    requires = [ unify.features.preservation.name ];
  };
}
