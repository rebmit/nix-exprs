{
  flake.unify.configs.nixos.flandre-t1 = {
    meta = {
      includes = [
        # keep-sorted start
        "tags/features/backup"
        "tags/features/baseline"
        "tags/features/immutable"
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
