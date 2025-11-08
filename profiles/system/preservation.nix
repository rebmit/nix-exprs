{
  unify.modules."system/preservation" = {
    nixos = {
      meta = {
        requires = [
          "external/preservation"
          "system/boot/initrd/systemd"
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
        };
    };
  };
}
