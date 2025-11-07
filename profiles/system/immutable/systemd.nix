{ lib, ... }:
let
  inherit (lib.modules) mkMerge;
in
{
  unify.modules."system/immutable" = {
    nixos.module = mkMerge [
      # initrd
      (
        { config, ... }:
        {
          assertions = [
            {
              assertion = !config.boot.isContainer;
              message = ''
                `config.boot.initrd.systemd.enable` and `config.boot.isContainer`
                cannot be enabled at the same time.
              '';
            }
          ];

          boot.initrd.systemd.enable = true;
        }
      )

      # machine-id
      (
        { ... }:
        {
          environment.etc."machine-id" = {
            source = "/var/lib/nixos/systemd/machine-id";
            mode = "direct-symlink";
          };

          boot.initrd.systemd.tmpfiles.settings.immutable = {
            "/sysroot/var/lib/nixos/systemd/machine-id".f = {
              user = "root";
              group = "root";
              mode = "0444";
            };
          };
        }
      )
    ];
  };
}
