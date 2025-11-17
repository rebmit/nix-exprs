{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  flake.unify.modules."programs/git" = {
    nixos = {
      module =
        { ... }:
        {
          programs.git = {
            enable = true;
            lfs.enable = true;
          };
        };
    };

    homeManager = {
      module =
        { ... }:
        {
          programs.git = {
            enable = true;
            lfs.enable = true;
            signing = {
              format = mkDefault "ssh";
              key = mkDefault "~/.ssh/id_ed25519";
            };
            settings = {
              commit.gpgSign = true;
              pull.rebase = true;
              init.defaultBranch = "master";
              fetch.prune = true;
            };
          };
        };
    };
  };
}
