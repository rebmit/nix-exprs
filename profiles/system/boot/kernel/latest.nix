{
  unify.modules."system/boot/kernel/latest" = {
    nixos = {
      meta = {
        tags = [ "base" ];
      };

      module =
        { pkgs, ... }:
        {
          boot.kernelPackages = pkgs.linuxPackages_latest;
        };
    };
  };
}
