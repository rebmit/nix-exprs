{ lib, ... }:
let
  inherit (lib.meta) getExe;
in
{
  perSystem =
    { config, ... }:
    {
      treefmt = {
        flakeCheck = false;
        projectRootFile = "flake.nix";
        programs = {
          # keep-sorted start block=yes
          deadnix = {
            enable = true;
            no-underscore = true;
          };
          keep-sorted.enable = true;
          nixfmt.enable = true;
          prettier.enable = true;
          shellcheck.enable = true;
          shfmt.enable = true;
          # keep-sorted end
        };
      };

      pre-commit.settings.hooks.treefmt = {
        enable = true;
        name = "treefmt";
        entry = getExe config.treefmt.build.wrapper;
        pass_filenames = false;
      };
    };
}
