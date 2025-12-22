{ self, ... }:
{
  flake.unify.modules."imports/enthalpy" = {
    nixos = {
      meta = {
        requires = [ "imports/netns" ];
      };

      module = self.nixosModules.enthalpy;
    };
  };
}
