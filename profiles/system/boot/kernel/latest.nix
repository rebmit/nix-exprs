{
  unify.modules."system/boot/kernel/latest" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
      };

      module =
        { pkgs, ... }:
        {
          boot.kernelPackages = pkgs.linuxPackages_latest;
        };
    };
  };
}
