{
  flake.modules.nixos.immutable = {
    users.mutableUsers = false;

    services.userborn = {
      enable = true;
      passwordFilesLocation = "/var/lib/nixos/userborn";
    };
  };
}
