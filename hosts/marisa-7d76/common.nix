{
  unify.hosts.nixos.marisa-7d76 = {
    meta = {
      tags = [ "base" ];
    };

    system = "x86_64-linux";

    module = _: {
      system.stateVersion = "25.11";

      # TODO: remove after test
      services.getty.autologinUser = "root";
      users.allowNoPasswordLogin = true;
    };
  };
}
