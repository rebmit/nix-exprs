{
  flake.unify.modules."system/boot/kernel/latest" = {
    nixos = {
      module =
        { pkgs, ... }:
        {
          boot.kernelPackages = pkgs.linuxPackages_latest;
        };
    };
  };
}
