{
  flake.unify.modules."system/preservation" = {
    nixos = {
      meta = {
        requires = [
          "external/preservation"
          "system/boot/initrd/systemd"
          "system/etc/machine-id"
        ];
      };

      module =
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
            persistentStoragePath = "/persist";
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

          virtualisation.vmVariant = {
            virtualisation = {
              emptyDiskImages = [ 1048576 ];
              fileSystems."/persist" = {
                device = "/dev/vdb";
                fsType = "ext4";
                neededForBoot = true;
                autoFormat = true;
              };
            };
          };
        };
    };
  };
}
