let
  common =
    { self, inputs, ... }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit self inputs; };
      };
    };
in
{
  unify.modules."external/home-manager" = {
    nixos.module =
      { inputs, config, ... }:
      {
        imports = [
          inputs.home-manager.nixosModules.home-manager
          common
        ];

        home-manager.sharedModules = [
          {
            home.stateVersion = config.system.stateVersion;
          }
        ];
      };

    darwin.module =
      { inputs, ... }:
      {
        imports = [
          inputs.home-manager.darwinModules.home-manager
          common
        ];

        home-manager.sharedModules = [
          {
            home.stateVersion = "25.11";
          }
        ];
      };
  };
}
