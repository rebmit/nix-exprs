{ config, ... }:
let
  home-manager = config.partitions.hosts.extraInputs.home-manager;
in
{
  unify.modules."external/home-manager" = {
    nixos.module = _: {
      imports = [ home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [
          (
            { osConfig, ... }:
            {
              home.stateVersion = osConfig.system.stateVersion;
            }
          )
        ];
      };
    };

    darwin.module = _: {
      imports = [ home-manager.darwinModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        sharedModules = [
          {
            home.stateVersion = "25.11";
          }
        ];
      };
    };
  };
}
