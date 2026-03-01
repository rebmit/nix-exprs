{ unify, ... }:
{
  flake.nixosModules.preservation = unify.lib.collectModules {
    class = "nixos";
    requires = [ unify.features.system._.preservation.name ];
  };
}
