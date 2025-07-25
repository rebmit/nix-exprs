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
          pkgs,
          lib,
          ...
        }:
        let
          workspace = inputs.uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };
          overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };
          pyprojectOverrides = _final: _prev: { };
          pythonSet =
            (pkgs.callPackage inputs.pyproject-nix.build.packages {
              python = pkgs.python312;
            }).overrideScope
              (
                lib.composeManyExtensions [
                  inputs.pyproject-build-systems.overlays.default
                  overlay
                  pyprojectOverrides
                ]
              );
        in
        {
          devshells.default = {
            packages = [
              (pythonSet.mkVirtualEnv "python-uv-env" workspace.deps.all)
              pkgs.python312Packages.uv
              pkgs.just
              config.treefmt.build.wrapper
            ];
            env = [
              (lib.nameValuePair "DEVSHELL_NO_MOTD" 1)
              (lib.nameValuePair "UV_PYTHON" "${lib.getExe pkgs.python312}")
              {
                name = "PYTHONPATH";
                unset = true;
              }
            ];
            devshell.startup.pre-commit-hook.text = config.pre-commit.installationScript;
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              deadnix.enable = true;
              ruff-check.enable = true;
              ruff-format.enable = true;
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
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
