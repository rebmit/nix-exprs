{
  unify.profiles.system._.linux._.userborn =
    { ... }:
    {
      nixos =
        { ... }:
        {
          users = {
            mutableUsers = false;
            users.root.createHome = true;
          };

          services.userborn = {
            enable = true;
            passwordFilesLocation = "/var/lib/nixos/userborn";
          };
        };
    };
}
