{
  flake.unify.modules."system/boot/initrd/systemd" = {
    nixos = {
      module =
        { ... }:
        {
          boot.initrd.systemd.enable = true;
        };
    };
  };
}
