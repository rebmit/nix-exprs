{
  unify.modules."external/home-manager" = {
    nixos.module =
      { inputs, ... }:
      {
        imports = [ inputs.home-manager.nixosModules.home-manager ];
      };

    darwin.module =
      { inputs, ... }:
      {
        imports = [ inputs.home-manager.darwinModules.home-manager ];
      };
  };
}
