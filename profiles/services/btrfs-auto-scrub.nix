{
  unify.modules."services/btrfs-auto-scrub" = {
    nixos.module = _: {
      services.btrfs.autoScrub.enable = true;

      # TODO: fixup
      passthru.preservation.config.btrfs-auto-scrub.directories = [
        {
          directory = "/var/lib/btrfs";
          mode = "0700";
          user = "root";
          group = "root";
        }
      ];
    };
  };
}
