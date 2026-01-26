{
  unify.profiles.system._.nixos._.initrd._.systemd =
    { ... }:
    {
      nixos =
        { ... }:
        {
          boot.initrd.systemd.enable = true;
        };
    };
}
