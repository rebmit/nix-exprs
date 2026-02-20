{ inputs, ... }:
{
  unify.profiles.system._.linux._.disko._.luks-btrfs-common =
    { ... }:
    {
      requires = [
        # keep-sorted start
        "profiles/system/linux/btrfs-auto-scrub"
        "profiles/system/linux/preservation"
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
                    cryptroot = {
                      label = "CRYPTROOT";
                      size = "100%";
                      content = {
                        type = "luks";
                        name = "cryptroot";
                        settings = {
                          allowDiscards = true;
                          bypassWorkqueues = true;
                          crypttabExtraOpts = [
                            "same-cpu-crypt"
                            "submit-from-crypt-cpus"
                          ];
                        };
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
          };

          fileSystems."/persist".neededForBoot = true;

          services.btrfs.autoScrub.fileSystems = [ "/persist" ];
        };
    };
}
