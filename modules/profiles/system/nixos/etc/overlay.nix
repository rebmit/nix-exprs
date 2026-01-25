{
  unify.profiles.system._.nixos._.etc._.overlay = {
    requires = [
      # keep-sorted start
      "profiles/system/nixos/etc/machine-id"
      "profiles/system/nixos/initrd/systemd"
      "profiles/system/nixos/userborn"
      # keep-sorted end
    ];

    nixos =
      { ... }:
      {
        system.etc.overlay = {
          enable = true;
          mutable = false;
        };

        environment.etc."NIXOS".text = "";
      };
  };
}
