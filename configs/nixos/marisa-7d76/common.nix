{
  flake.unify.configs.nixos.marisa-7d76 = {
    meta = {
      includes = [
        # keep-sorted start
        "tags/backup"
        "tags/baseline"
        "tags/desktop"
        "tags/immutable"
        "tags/multimedia"
        "tags/workstation"
        # keep-sorted end
      ];
    };

    system = "x86_64-linux";

    submodules.home-manager.users.rebmit = {
      meta = {
        includes = [
          # keep-sorted start
          "tags/baseline"
          "tags/development"
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
