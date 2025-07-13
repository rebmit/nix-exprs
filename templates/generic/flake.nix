{
  outputs =
    inputs@{ flake-parts, rebmit, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      inherit (rebmit.lib) systems;
      imports = [
        inputs.devshell.flakeModule
        inputs.git-hooks-nix.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.rebmit.flakeModule
      ];
      perSystem =
        {
          config,
          lib,
          ...
        }:
        {
          devshells.default = {
            packages = [
              config.treefmt.build.wrapper
            ];
            env = [
              (lib.nameValuePair "DEVSHELL_NO_MOTD" 1)
            ];
            devshell.startup.pre-commit-hook.text = config.pre-commit.installationScript;
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
            };
          };

          pre-commit.settings.hooks.treefmt = {
            enable = true;
            name = "treefmt";
            entry = lib.getExe config.treefmt.build.wrapper;
            pass_filenames = false;
          };
        };
    };

  inputs = {
    # flake-parts

    flake-parts.follows = "rebmit/flake-parts";

    # nixpkgs

    nixpkgs.url = "github:rebmit/nixpkgs/nixos-unstable";

    # flake modules

    devshell.follows = "rebmit/devshell";
    git-hooks-nix.follows = "rebmit/git-hooks-nix";
    treefmt-nix.follows = "rebmit/treefmt-nix";

    # libraries

    rebmit = {
      url = "https://git.rebmit.moe/rebmit/nix-exprs/archive/master.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
