{
  unify.profiles.system._.linux._.initrd._.systemd =
    { ... }:
    {
      nixos =
        { ... }:
        {
          boot.initrd.systemd.enable = true;
        };
    };
}
