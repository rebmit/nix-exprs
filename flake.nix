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
      inherit (nixpkgs) lib;
      inherit (lib.attrsets) optionalAttrs;
      inherit (lib.modules) mkForce mkMerge;
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, partitionStack, ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        imports = [ flake-parts.flakeModules.partitions ];

        partitions = {
          # keep-sorted start block=yes
          dev = {
            extraInputsFlake = ./dev/_flake;
            module = import-tree ./dev;
          };
          lib.module = import-tree ./lib;
          modules.module = import-tree ./modules;
          pkgs.module = import-tree ./pkgs;
          profiles.module = import-tree ./profiles;
          # keep-sorted end
        };

        flake = optionalAttrs (partitionStack == [ ]) (
          let
            partitionAttr =
              partition: attrName: mkForce config.partitions.${partition}.module.flake.${attrName};
          in
          {
            # keep-sorted start block=yes
            checks = mkMerge [
              (partitionAttr "modules" "checks")
              (partitionAttr "pkgs" "checks")
              (partitionAttr "profiles" "checks")
            ];
            devShells = partitionAttr "dev" "devShells";
            flakeModules = partitionAttr "modules" "flakeModules";
            formatter = partitionAttr "dev" "formatter";
            legacyPackages = partitionAttr "profiles" "legacyPackages";
            lib = partitionAttr "lib" "lib";
            modules = partitionAttr "profiles" "modules";
            nixosConfigurations = partitionAttr "profiles" "nixosConfigurations";
            nixosModules = partitionAttr "modules" "nixosModules";
            overlays = partitionAttr "pkgs" "overlays";
            packages = partitionAttr "pkgs" "packages";
            # keep-sorted end
          }
        );
      }
    );
}
