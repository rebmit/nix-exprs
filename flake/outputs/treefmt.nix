{
  perSystem =
    {
      config,
      lib,
      ...
    }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          deadnix.enable = true;
          prettier.enable = true;
        };
      };

      devshells.default.packages = lib.singleton config.treefmt.build.wrapper;

      pre-commit.settings.hooks = {
        treefmt = {
          enable = true;
          name = "treefmt";
          entry = lib.getExe config.treefmt.build.wrapper;
          pass_filenames = false;
        };
      };
    };
}
