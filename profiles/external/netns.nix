{ self, ... }:
{
  unify.modules."external/netns" = {
    nixos.module = self.nixosModules.netns;
  };
}
