{ lib, ... }:
let
  inherit (lib.modules) mkVMOverride;
in
{
  flake.unify.modules."services/btrfs-auto-scrub" = {
    nixos = {
      meta = {
        requires = [ "external/preservation" ];
      };

      module =
        { ... }:
        {
          services.btrfs.autoScrub.enable = true;

          preservation.preserveAt.state.directories = [
            {
              directory = "/var/lib/btrfs";
              mode = "0700";
              user = "root";
              group = "root";
            }
          ];

          virtualisation.vmVariant = {
            services.btrfs.autoScrub.enable = mkVMOverride false;
          };
        };
    };
  };
}
