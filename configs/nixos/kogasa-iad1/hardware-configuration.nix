{
  flake.unify.configs.nixos.kogasa-iad1 = {
    meta = {
      includes = [ "system/disko/btrfs-common" ];
    };

    module =
      { modulesPath, ... }:
      {
        imports = [
          (modulesPath + "/profiles/qemu-guest.nix")
        ];

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
