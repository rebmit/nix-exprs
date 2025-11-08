{ config, ... }:
let
  disko = config.partitions.hosts.extraInputs.disko;
in
{
  unify.modules."external/disko" = {
    nixos.module = disko.nixosModules.disko;
  };
}
