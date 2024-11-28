# Portions of this file are sourced from
# https://github.com/TyberiusPrime/uv2nix_hammer_overrides (MIT License)
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
          pyprojectOverrides = final: prev: {
            nvidia-cusolver-cu12 = prev.nvidia-cusolver-cu12.overrideAttrs (old: {
              buildInputs = old.buildInputs or [ ] ++ [
                pkgs.cudaPackages_12_4.libcublas
                pkgs.cudaPackages_12_4.libcusparse
                pkgs.cudaPackages_12_4.libnvjitlink
              ];
            });
            nvidia-cusparse-cu12 = prev.nvidia-cusparse-cu12.overrideAttrs (old: {
              buildInputs = old.buildInputs or [ ] ++ [
                pkgs.cudaPackages_12_4.libnvjitlink
              ];
            });
            torch = prev.torch.overrideAttrs (old: {
              buildInputs =
                old.buildInputs or [ ]
                ++ (pkgs.lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
                  pkgs.cudaPackages_12_4.cuda_cudart
                ])
                ++ [
                  pkgs.cudaPackages_12_4.cuda_cupti
                  pkgs.cudaPackages_12_4.cuda_nvrtc
                  pkgs.cudaPackages_12_4.cudnn
                  pkgs.cudaPackages_12_4.libcublas
                  pkgs.cudaPackages_12_4.libcufft
                  pkgs.cudaPackages_12_4.libcurand
                  pkgs.cudaPackages_12_4.libcusolver
                  pkgs.cudaPackages_12_4.libcusparse
                  pkgs.cudaPackages_12_4.nccl
                ];
            });
            torchvision = prev.torchvision.overrideAttrs (old: {
              buildInputs =
                old.buildInputs or [ ]
                ++ (pkgs.lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
                  pkgs.cudaPackages_12_4.cuda_cudart
                ]);
              preFixup = pkgs.lib.optionals (!pkgs.stdenv.isDarwin) ''
                addAutoPatchelfSearchPath "${final.torch}/${final.python.sitePackages}/torch/lib"
              '';
            });
          };
          pythonSet =
            (pkgs.callPackage inputs.pyproject-nix.build.packages {
              python = pkgs.python311;
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
              pkgs.python311Packages.uv
              pkgs.just
              config.treefmt.build.wrapper
            ];
            env = [
              (lib.nameValuePair "UV_PYTHON" "${lib.getExe pkgs.python311}")
              (lib.nameValuePair "DEVSHELL_NO_MOTD" 1)
              {
                name = "PYTHONPATH";
                unset = true;
              }
            ];
            devshell.startup.pre-commit-hook.text = config.pre-commit.installationScript;
          };

          nixpkgs.config = {
            allowUnfree = true;
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
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

    nixpkgs.follows = "rebmit/nixpkgs";
    nixpkgs-unstable.follows = "rebmit/nixpkgs-unstable";

    # flake modules

    devshell.follows = "rebmit/devshell";
    git-hooks-nix.follows = "rebmit/git-hooks-nix";
    treefmt-nix.follows = "rebmit/treefmt-nix";

    # libraries

    rebmit.url = "github:rebmit/nix-exprs";
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
