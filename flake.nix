{
  inputs = {
    # keep-sorted start block=yes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:rebmit/nixpkgs";
    # keep-sorted end
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      import-tree,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      inherit (lib) types;
      inherit (lib.attrsets)
        getAttrFromPath
        optionalAttrs
        ;
      inherit (lib.modules) evalModules mkMerge mkOptionDefault;
      inherit (lib.options) mkOption;
      inherit (lib.strings) splitString;
    in
    (evalModules {
      specialArgs = {
        inherit inputs self;
        flake-parts-lib = flake-parts.lib;
        moduleLocation = "${self.outPath}/flake.nix";
        partitionStack = [ ];
      };

      class = "flake";

      modules = [
        # keep-sorted start
        "${flake-parts}/modules/debug.nix"
        "${flake-parts}/modules/moduleWithSystem.nix"
        "${flake-parts}/modules/perSystem.nix"
        "${flake-parts}/modules/transposition.nix"
        "${flake-parts}/modules/withSystem.nix"
        flake-parts.flakeModules.partitions
        # keep-sorted end

        {
          transposition = mkOptionDefault { };

          systems = [
            "x86_64-linux"
            "aarch64-linux"
            "aarch64-darwin"
          ];
        }

        {
          options.flake = mkOption {
            type = types.submoduleWith {
              modules = [
                { freeformType = types.lazyAttrsOf (types.uniq types.raw); }
                ./schema.nix
              ];
            };
            description = ''
              Raw flake output attributes.
            '';
          };
        }

        (
          { config, partitionStack, ... }:
          let
            partitionAttr =
              partition: attrPath:
              (getAttrFromPath (splitString "/" attrPath) config.partitions.${partition}.module.flake);
          in
          optionalAttrs (partitionStack == [ ]) {
            partitions = {
              # keep-sorted start block=yes
              dev = {
                extraInputsFlake = ./dev/_flake;
                module = import-tree ./dev;
              };
              lib.module = import-tree ./lib;
              modules = {
                extraInputsFlake = ./modules/_flake;
                module = import-tree ./modules;
              };
              pkgs = {
                extraInputsFlake = ./pkgs/_flake;
                module = import-tree ./pkgs;
              };
              # keep-sorted end
            };

            flake = {
              # keep-sorted start block=yes
              checks = mkMerge [
                # keep-sorted start
                (partitionAttr "modules" "checks")
                (partitionAttr "pkgs" "checks")
                # keep-sorted end
              ];
              darwinConfigurations = partitionAttr "modules" "darwinConfigurations";
              devShells = partitionAttr "dev" "devShells";
              flakeModules = partitionAttr "modules" "flakeModules";
              formatter = partitionAttr "dev" "formatter";
              legacyPackages = partitionAttr "pkgs" "legacyPackages";
              lib = partitionAttr "lib" "lib";
              nixosConfigurations = partitionAttr "modules" "nixosConfigurations";
              nixosModules = partitionAttr "modules" "nixosModules";
              overlays = partitionAttr "pkgs" "overlays";
              partitions = config.partitions;
              # keep-sorted end
            };
          }
        )
      ];
    }).config.flake;
}
