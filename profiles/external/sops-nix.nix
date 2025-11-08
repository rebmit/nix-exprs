{ config, ... }:
let
  sops-nix = config.partitions.hosts.extraInputs.sops-nix;
in
{
  unify.modules."external/sops-nix" = {
    nixos.module = sops-nix.nixosModules.sops;
  };
}
