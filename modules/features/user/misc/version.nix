{ lib, __findFile, ... }:

{ user, ... }:

{
  includes = [ <rebmit/features/user/misc/class> ];

  configs.user =
    { ... }:
    {
      options = {
        home = {
          homeManager = {
            stateVersion = lib.mkOption {
              type = lib.types.str;
              description = ''
                System state version for compatibility.
              '';
            };
          };
        };
      };
    };

  modules.homeManager =
    { ... }:
    let
      homeManager = user.home.homeManager;
    in
    {
      home = {
        version = {
          revision = homeManager.path.revision or homeManager.path.rev or null;
        };

        stateVersion = homeManager.stateVersion;
      };
    };
}
