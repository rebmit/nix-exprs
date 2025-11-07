{
  description = "a collection of common nix expressions used by rebmit";

  inputs = {
    # flake-parts

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    # nixpkgs

    nixpkgs.url = "github:rebmit/nixpkgs/nixos-unstable";

    # libraries

    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    let
      lib = nixpkgs.lib;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.partitions
      ]
      ++ (inputs.import-tree.withLib inputs.nixpkgs.lib).leafs ./modules;
      partitionedAttrs = {
        devShells = "dev";
        formatter = "dev";
        lib = "lib";
        overlays = "pkgs";
        packages = "pkgs";
      };
      partitions = {
        dev = {
          extraInputsFlake = ./dev;
          module =
            (inputs.import-tree.initFilter (p: !lib.hasSuffix "/flake.nix" p && lib.hasSuffix ".nix" p))
              ./dev;
        };
        lib.module = inputs.import-tree ./lib;
        pkgs.module = inputs.import-tree ./pkgs;
      };
    };
}
