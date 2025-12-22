{ self, ... }:
{
  flake.unify.modules."imports/netns" = {
    nixos = {
      module = self.nixosModules.netns;
    };
  };
}
