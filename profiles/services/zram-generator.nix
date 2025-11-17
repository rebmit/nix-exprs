{
  flake.unify.modules."services/zram-generator" = {
    nixos = {
      meta = {
        requires = [ "system/boot/sysctl/zram-vm-optimization" ];
      };

      module =
        { ... }:
        {
          services.zram-generator = {
            enable = true;
            settings.zram0 = {
              compression-algorithm = "zstd";
              zram-size = "ram / 2";
            };
          };
        };
    };
  };
}
