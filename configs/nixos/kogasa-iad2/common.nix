{
  flake.unify.configs.nixos.kogasa-iad2 = {
    meta = {
      includes = [
        # keep-sorted start
        "tags/features/backup"
        "tags/features/baseline"
        "tags/features/immutable"
        "tags/features/network"
        "tags/roles/server"
        # keep-sorted end
      ];
    };

    system = "x86_64-linux";

    module =
      { ... }:
      {
        system.stateVersion = "25.11";
      };
  };
}
