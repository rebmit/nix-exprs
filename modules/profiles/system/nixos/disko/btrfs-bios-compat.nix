{ inputs, ... }:
{
  unify.profiles.system._.nixos._.disko._.btrfs-bios-compat = {
    requires = [
      # keep-sorted start
      "profiles/system/nixos/btrfs-auto-scrub"
      "profiles/system/nixos/preservation"
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
}
