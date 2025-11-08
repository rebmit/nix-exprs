{
  unify.modules."system/etc/overlay" = {
    nixos = {
      meta = {
        tags = [ "immutable" ];
        requires = [ "system/boot/initrd/systemd" ];
      };

      module = _: {
        system.etc.overlay = {
          enable = true;
          mutable = false;
        };

        environment.etc."machine-id" = {
          source = "/var/lib/nixos/systemd/machine-id";
          mode = "direct-symlink";
        };

        boot.initrd.systemd.tmpfiles.settings.immutable = {
          "/sysroot/var/lib/nixos/systemd/machine-id".f = {
            user = "root";
            group = "root";
            mode = "0444";
          };
        };
      };
    };
  };
}
