{
  flake.unify.configs.nixos.momiji-nrt0 = {
    meta = {
      includes = [
        # keep-sorted start
        "system/disko/btrfs-bios-compat"
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
            "ahci"
            "xhci_pci"
            "virtio_pci"
            "sr_mod"
            "virtio_blk"
          ];
          kernelModules = [ "kvm-amd" ];
        };
      };
  };
}
