{
  flake.modules.nixos.immutable = {
    users = {
      mutableUsers = false;
      users.root.createHome = true;
    };

    services.userborn = {
      enable = true;
      passwordFilesLocation = "/var/lib/nixos/userborn";
    };
  };
}
