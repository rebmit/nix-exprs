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
      inherit (lib.attrsets) optionalAttrs getAttrFromPath;
      inherit (lib.modules) mkMerge;
      inherit (lib.strings) splitString;
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
          hosts = {
            extraInputsFlake = ./hosts/_flake;
            module = inputs.import-tree ./hosts;
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
              partition: attrPath:
              (getAttrFromPath (splitString "/" attrPath) config.partitions.${partition}.module.flake);
          in
          {
            # keep-sorted start block=yes
            checks = mkMerge [
              (partitionAttr "hosts" "checks")
              (partitionAttr "modules" "checks")
              (partitionAttr "pkgs" "checks")
              (partitionAttr "profiles" "checks")
            ];
            devShells = partitionAttr "dev" "devShells";
            flakeModules = partitionAttr "modules" "flakeModules";
            formatter = partitionAttr "dev" "formatter";
            legacyPackages = partitionAttr "profiles" "legacyPackages";
            lib = partitionAttr "lib" "lib";
            meta = partitionAttr "profiles" "meta";
            modules = partitionAttr "profiles" "modules";
            nixosConfigurations = partitionAttr "hosts" "nixosConfigurations";
            nixosModules = partitionAttr "modules" "nixosModules";
            overlays = partitionAttr "pkgs" "overlays";
            packages = partitionAttr "pkgs" "packages";
            # keep-sorted end
          }
        );
      }
    );
}
