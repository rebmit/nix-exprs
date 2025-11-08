{ self, ... }:
{
  unify.modules."external/preservation" = {
    nixos.module = self.nixosModules.preservation;
  };
}
