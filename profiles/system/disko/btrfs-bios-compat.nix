{
  flake.unify.modules."system/disko/btrfs-bios-compat" = {
    nixos = {
      meta = {
        requires = [
          "imports/disko"
          "services/btrfs-auto-scrub"
          "system/preservation"
        ];
        conflicts = [
          "system/disko/btrfs-common"
          "system/disko/luks-btrfs-common"
        ];
      };

      module =
        { ... }:
        {
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
                    boot = {
                      type = "EF02";
                      label = "BOOT";
                      start = "0";
                      end = "+1M";
                    };
                    root = {
                      label = "ROOT";
                      end = "-0";
                      content = {
                        type = "btrfs";
                        extraArgs = [ "-f" ];
                        subvolumes = {
                          "/boot" = {
                            mountpoint = "/boot";
                            mountOptions = [ "compress=zstd" ];
                          };
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
  };
}
