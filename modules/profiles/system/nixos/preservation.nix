{
  unify.profiles.system._.nixos._.preservation =
    { ... }:
    {
      requires = [
        # keep-sorted start
        "features/preservation"
        "profiles/system/nixos/etc/machine-id"
        "profiles/system/nixos/initrd/systemd"
        # keep-sorted end
      ];

      nixos =
        { config, ... }:
        {
          assertions = [
            {
              assertion = config.fileSystems ? "/persist";
              message = ''
                `config.fileSystems."/persist"` must be set.
              '';
            }
          ];

          preservation = {
            enable = true;
            preserveAt = {
              cache = {
                persistentStoragePath = "/persist/cache";
                directories = [
                  "/var/tmp"
                ];
              };
              state = {
                persistentStoragePath = "/persist/state";
                directories = [
                  {
                    directory = "/var/lib/nixos";
                    inInitrd = true;
                    mode = "0755";
                    user = "root";
                    group = "root";
                  }
                  "/var/lib/systemd"
                  "/var/log/journal"
                ];
              };
            };
          };

          virtualisation.vmVariant = {
            virtualisation = {
              diskImage = null;
              emptyDiskImages = [ 512 ];
              fileSystems."/persist" = {
                device = "/dev/vda";
                fsType = "ext4";
                neededForBoot = true;
                autoFormat = true;
              };
            };
          };
        };
    };
}
