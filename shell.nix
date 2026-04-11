{
  inputs ? import ./flake,
  lib ? nixpkgs.lib,

  flake-parts ? inputs.flake-parts,
  nixpkgs ? inputs.nixpkgs,
}:

let
  compat = lib.evalModules {
    specialArgs = {
      inherit inputs;
      flake-parts-lib = flake-parts.lib;
    };

    class = "flake";

    modules = [
      # keep-sorted start
      "${flake-parts}/modules/flake.nix"
      "${flake-parts}/modules/moduleWithSystem.nix"
      "${flake-parts}/modules/perSystem.nix"
      "${flake-parts}/modules/transposition.nix"
      "${flake-parts}/modules/withSystem.nix"
      # keep-sorted end

      {
        transposition = lib.mkOptionDefault { };

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        imports = [
          ./dev/common.nix
          ./dev/devshell/infra.nix
          ./dev/devshell/secrets.nix
          ./dev/git-hooks.nix
          ./dev/treefmt.nix
        ];
      }
    ];
  };
in
compat.config.flake.devShells.${builtins.currentSystem}.default
