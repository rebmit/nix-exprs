{
  flake.unify.configs.nixos.marisa-7d76 = {
    meta = {
      tags = [
        # keep-sorted start
        "backup"
        "baseline"
        "desktop"
        "immutable"
        "multimedia"
        "workstation"
        # keep-sorted end
      ];
    };

    system = "x86_64-linux";

    submodules.home-manager.users.rebmit = {
      meta = {
        tags = [
          # keep-sorted start
          "baseline"
          "development"
          # keep-sorted end
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
