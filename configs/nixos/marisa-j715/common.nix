{ lib, ... }:
let
  inherit (lib.modules) mkForce;
in
{
  flake.unify.configs.nixos.marisa-j715 = {
    meta = {
      includes = [
        # keep-sorted start
        "tags/features/backup"
        "tags/features/baseline"
        "tags/features/development"
        "tags/features/immutable"
        "tags/features/network"
        "tags/roles/workstation"
        # keep-sorted end
      ];
    };

    system = "aarch64-linux";

    submodules.home-manager.users.rebmit = {
      meta = {
        includes = [
          # keep-sorted start
          "tags/features/baseline"
          "tags/features/development"
          # keep-sorted end
        ];
      };

      module =
        { ... }:
        {
          programs.git = {
            signing.key = mkForce "~/.ssh/id_ed25519_sk_rk.pub";
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
