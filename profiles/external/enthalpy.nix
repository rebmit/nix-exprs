{ self, ... }:
{
  unify.modules."external/enthalpy" = {
    nixos.module = self.nixosModules.enthalpy;
  };
}
