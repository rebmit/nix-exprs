{ lib, ... }:
let
  inherit (lib.modules) mkVMOverride;
in
{
  unify.features.system._.os-specific._.linux._.btrfs-auto-scrub =
    { ... }:
    {
      requires = [ "features/system/preservation" ];

      nixos =
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
}
