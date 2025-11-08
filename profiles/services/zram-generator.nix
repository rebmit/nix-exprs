{
  unify.modules."services/zram-generator" = {
    nixos.module = _: {
      services.zram-generator = {
        enable = true;
        settings.zram0 = {
          compression-algorithm = "zstd";
          zram-size = "ram / 2";
        };
      };
    };
  };
}
