{
  unify.modules."services/btrfs-auto-scrub" = {
    nixos = {
      meta = {
        requires = [ "external/preservation" ];
      };

      module = _: {
        services.btrfs.autoScrub.enable = true;

        preservation.directories = [
          {
            directory = "/var/lib/btrfs";
            mode = "0700";
            user = "root";
            group = "root";
          }
        ];
      };
    };
  };
}
