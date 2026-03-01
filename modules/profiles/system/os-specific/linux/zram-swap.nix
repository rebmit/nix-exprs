{
  unify.profiles.system._.os-specific._.linux._.zram-swap =
    { ... }:
    {
      nixos =
        { ... }:
        {
          services.zram-generator = {
            enable = true;
            settings.zram0 = {
              compression-algorithm = "zstd";
              zram-size = "ram / 2";
            };
          };

          # https://wiki.archlinux.org/title/Zram#Optimizing_swap_on_zram
          boot.kernel.sysctl = {
            "vm.swappiness" = 180;
            "vm.watermark_boost_factor" = 0;
            "vm.watermark_scale_factor" = 125;
            "vm.page-cluster" = 0;
          };
        };
    };
}
