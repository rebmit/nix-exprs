{ name, lib, ... }:

{ user, ... }:

{
  configs.user =
    { ... }:
    {
      options = {
        userName = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = ''
            The username for this user.
          '';
        };
      };

      config = {
        __key__ = lib.mkDefault user.config.userName;
      };
    };

  modules.darwin =
    { ... }:
    {
      users.users.${user.config.userName} = { };
    };

  modules.homeManager =
    { ... }:
    {
      home.username = user.config.userName;
    };

  modules.nixos =
    { ... }:
    {
      users.users.${user.config.userName} = { };
    };
}
