{
  flake.unify.modules."system/userborn" = {
    nixos = {
      meta = {
        tags = [ "immutable" ];
      };

      module =
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
  };
}
