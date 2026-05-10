{ lib, ... }:

{ user, ... }:

let
  cfg = user.config.home;
in
{
  configs.user =
    { ... }:
    {
      options = {
        home = {
          homeManager = {
            stateVersion = lib.mkOption {
              type = lib.types.str;
              description = ''
                Home state version for compatibility.
              '';
            };
          };
        };
      };
    };

  modules.homeManager =
    { ... }:
    {
      home = {
        stateVersion = cfg.homeManager.stateVersion;
      };
    };
}
