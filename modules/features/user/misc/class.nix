{ inputs, lib, ... }:

{
  configs.user =
    { ... }:
    {
      options = {
        home = {
          class = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.enum [
                "homeManager"
              ]
            );
            default = null;
            description = ''
              Module system class of the user.
            '';
          };

          homeManager = {
            path = lib.mkOption {
              type = lib.types.path;
              default = inputs.home-manager;
              description = ''
                Path to the home-manager source tree to be imported.
              '';
            };
          };
        };
      };
    };

  modules.homeManager = { };
}
