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
    };

    system = "x86_64-linux";

    submodules.home-manager.users.rebmit = {
      meta = {
        includes = [
          # keep-sorted start
          "tags/features/baseline"
          "tags/features/desktop"
          "tags/features/development"
          # keep-sorted end
        ];
      };

      module =
        { ... }:
        {
          programs.niri.settings = {
            outputs = {
              "HDMI-A-1" = {
                scale = 1.75;
              };
              "DP-1" = {
                scale = 1.75;
                position = {
                  x = 0;
                  y = 0;
                };
              };
            };
          };
        };
    };

    module =
      { ... }:
      {
        system.stateVersion = "25.11";
      };
  };
}
