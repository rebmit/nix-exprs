{
  unify.modules."services/zram-generator" = {
    nixos = {
      meta = {
        tags = [
          "server"
          "workstation"
        ];
        requires = [ "system/boot/sysctl/zram-vm-optimization" ];
      };

      module = _: {
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
