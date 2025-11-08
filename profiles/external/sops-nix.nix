{ inputs, ... }:
{
  unify.modules."external/sops-nix" = {
    nixos.module = inputs.sops-nix.nixosModules.sops;
  };
}
