{
  unify.profiles.system._.os-specific._.linux._.initrd._.systemd =
    { ... }:
    {
      nixos =
        { ... }:
        {
          boot.initrd.systemd.enable = true;
        };
    };
}
