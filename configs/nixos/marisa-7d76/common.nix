{
  flake.unify.configs.nixos.marisa-7d76 = {
    meta = {
      includes = [
        # keep-sorted start
        "tags/features/backup"
        "tags/features/baseline"
        "tags/features/desktop"
        "tags/features/development"
        "tags/features/immutable"
        "tags/features/multimedia"
        "tags/features/network"
        "tags/roles/workstation"
        # keep-sorted end
      ];
      excludes = [
        # keep-sorted start
        "system/boot/kernel/latest"
        # keep-sorted end
      ];
    };

    system = "x86_64-linux";

    submodules.home-manager.users.rebmit = {
      meta = {
        includes = [
          # keep-sorted start
          "programs/minecraft"
          "tags/features/baseline"
          "tags/features/desktop"
          "tags/features/development"
          # keep-sorted end
        ];
      };

      module =
        { ... }:
        {
          services.kanshi.settings =
            let
              monitor = "PNP(AOC) U2790B 0x00011D7B";
            in
            [
              {
                output = {
                  criteria = monitor;
                  scale = 1.75;
                };
              }
              {
                profile = {
                  name = "default";
                  outputs = [
                    {
                      criteria = monitor;
                      position = "0,0";
                    }
                  ];
                };
              }
            ];
        };
    };

    module =
      { ... }:
      {
        system.stateVersion = "25.11";
      };
  };
}
