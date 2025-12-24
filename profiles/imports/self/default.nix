{ self, ... }:
{
  flake.unify.modules."imports/self/default" = {
    nixos = {
      module = self.nixosModules.default;
    };
  };
}
