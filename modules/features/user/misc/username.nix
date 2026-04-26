{ lib, ... }:

{ user, ... }:

{
  configs.user =
    { ... }:
    {
      options = {
        userName = lib.mkOption {
          type = lib.types.str;
          description = ''
            The username for this user.
          '';
        };
      };

      config = {
        __key__ = lib.mkDefault user.userName;
      };
    };

  modules.darwin =
    { ... }:
    {
      users.users.${user.userName} = { };
    };

  modules.homeManager =
    { ... }:
    {
      home.username = user.userName;
    };

  modules.nixos =
    { ... }:
    {
      users.users.${user.userName} = { };
    };
}
