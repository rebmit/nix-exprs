{
  unify.profiles.system._.os-specific._.linux._.etc._.overlay =
    { ... }:
    {
      requires = [
        # keep-sorted start
        "profiles/system/os-specific/linux/etc/machine-id"
        "profiles/system/os-specific/linux/initrd/systemd"
        "profiles/system/os-specific/linux/userborn"
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
