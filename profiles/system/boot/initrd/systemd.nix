{
  flake.unify.modules."system/boot/initrd/systemd" = {
    nixos.module = _: {
      boot.initrd.systemd.enable = true;
    };
  };
}
