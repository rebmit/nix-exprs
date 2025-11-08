{ inputs, ... }:
{
  unify.modules."external/disko" = {
    nixos.module = inputs.disko.nixosModules.disko;
  };
}
