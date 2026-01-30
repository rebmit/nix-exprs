{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  unify.profiles.users._.username =
    { user, ... }:
    {
      contexts.user =
        { config, ... }:
        {
          options = {
            userName = mkOption {
              type = types.str;
              default = config.name;
              description = ''
                The username for this user.
              '';
            };
          };
        };

      nixos =
        { ... }:
        {
          users.users.${user.userName} = { };
        };

      darwin =
        { ... }:
        {
          users.users.${user.userName} = { };
        };

      homeManager =
        { ... }:
        {
          home.username = user.userName;
        };
    };
}
