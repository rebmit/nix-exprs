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
    inputs@{
      flake-parts,
      nixpkgs,
      import-tree,
      ...
    }:
    let
      lib = nixpkgs.lib;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        flake-parts.flakeModules.partitions
      ]
      ++ (import-tree.withLib lib).leafs ./modules;
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
            (import-tree.initFilter (p: !lib.hasSuffix "/flake.nix" p && lib.hasSuffix ".nix" p))
              ./dev;
        };
        lib.module = import-tree ./lib;
        pkgs.module = import-tree ./pkgs;
      };
    };
}
