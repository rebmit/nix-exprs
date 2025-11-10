{ self, ... }:
{
  unify.modules."external/enthalpy" = {
    nixos = {
      meta = {
        requires = [ "external/netns" ];
      };

      module = self.nixosModules.enthalpy;
    };
  };
}
