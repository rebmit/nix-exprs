{
  unify.profiles.system._.linux._.etc._.overlay =
    { ... }:
    {
      requires = [
        # keep-sorted start
        "profiles/system/linux/etc/machine-id"
        "profiles/system/linux/initrd/systemd"
        "profiles/system/linux/userborn"
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
