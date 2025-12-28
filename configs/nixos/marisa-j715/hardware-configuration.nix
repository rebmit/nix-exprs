{
  flake.unify.configs.nixos.marisa-j715 = {
    meta = {
      includes = [ "system/disko/btrfs-common" ];
    };

    module =
      { ... }:
      {
        disko.devices = {
          nodev."/".mountOptions = [ "size=6G" ];
          disk.main.device = "/dev/vda";
        };

        boot = {
          loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot.enable = true;
          };
          initrd.availableKernelModules = [ "xhci_pci" ];
        };
      };
  };
}
