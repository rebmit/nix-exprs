{ inputs, ... }:
{
  unify.features.system._.os-specific._.linux._.disko._.btrfs-common =
    { ... }:
    {
      requires = [
        # keep-sorted start
        "features/system/os-specific/linux/btrfs-auto-scrub"
        "features/system/os-specific/linux/preservation"
        # keep-sorted end
      ];

      nixos =
        { ... }:
        {
          imports = [ inputs.disko.nixosModules.disko ];

          disko.devices = {
            nodev = {
              "/" = {
                fsType = "tmpfs";
                mountOptions = [
                  "defaults"
                  "mode=755"
                  "nosuid"
                  "nodev"
                ];
              };
            };
            disk = {
              main = {
                type = "disk";
                content = {
                  type = "gpt";
                  partitions = {
                    esp = {
                      label = "ESP";
                      size = "2G";
                      type = "EF00";
                      content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                        mountOptions = [ "umask=0077" ];
                      };
                    };
                    root = {
                      label = "ROOT";
                      size = "100%";
                      content = {
                        type = "btrfs";
                        extraArgs = [ "-f" ];
                        subvolumes = {
                          "/nix" = {
                            mountpoint = "/nix";
                            mountOptions = [ "compress=zstd" ];
                          };
                          "/persist" = {
                            mountpoint = "/persist";
                            mountOptions = [ "compress=zstd" ];
                          };
                        };
                      };
                    };
                  };
                };
              };
            };
          };

          fileSystems."/persist".neededForBoot = true;

          services.btrfs.autoScrub.fileSystems = [ "/persist" ];
        };
    };
}
