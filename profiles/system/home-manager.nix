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
  unify.modules."system/home-manager" = {
    nixos = {
      meta = {
        requires = [ "external/home-manager" ];
      };

      module =
        { config, ... }:
        {
          imports = [ common ];

          home-manager.sharedModules = [
            {
              home.stateVersion = config.system.stateVersion;
            }
          ];
        };
    };

    darwin = {
      meta = {
        requires = [ "external/home-manager" ];
      };

      module = _: {
        imports = [ common ];

        home-manager.sharedModules = [
          {
            home.stateVersion = "25.11";
          }
        ];
      };
    };
  };
}
