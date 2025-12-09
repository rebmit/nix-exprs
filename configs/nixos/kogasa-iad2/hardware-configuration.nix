{
  flake.unify.configs.nixos.kogasa-iad2 = {
    meta = {
      includes = [
        # keep-sorted start
        "system/disko/btrfs-common"
        "virtualisation/qemu-guest"
        # keep-sorted end
      ];
    };

    module =
      { ... }:
      {
        disko.devices = {
          nodev."/".mountOptions = [ "size=2G" ];
          disk.main.device = "/dev/vda";
        };

        boot = {
          initrd.availableKernelModules = [
            "ata_piix"
            "uhci_hcd"
            "virtio_pci"
            "sr_mod"
            "virtio_blk"
          ];
          loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot.enable = true;
          };
        };
      };
  };
}
