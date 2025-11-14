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
          deadnix.enable = true;
          shfmt.enable = true;
          keep-sorted.enable = true;
          nixfmt.enable = true;
          prettier.enable = true;
          shellcheck.enable = true;
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
