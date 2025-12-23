{
  inputs = {
    # keep-sorted start block=yes
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:rebmit/nixpkgs/nixos-unstable";
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
      inherit (lib.attrsets) getAttrFromPath optionalAttrs;
      inherit (lib.modules) evalModules mkOptionDefault;
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
        "${flake-parts}/modules/flake.nix"
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

        (
          { config, partitionStack, ... }:
          let
            partitionAttr =
              partition: attrPath:
              (getAttrFromPath (splitString "/" attrPath) config.partitions.${partition}.module);
          in
          optionalAttrs (partitionStack == [ ]) {
            partitions = {
              # keep-sorted start block=yes
              dev = {
                extraInputsFlake = ./dev/_flake;
                module = import-tree ./dev;
              };
              # keep-sorted end
            };

            flake = {
              # keep-sorted start block=yes
              devShells = partitionAttr "dev" "flake/devShells";
              formatter = partitionAttr "dev" "flake/formatter";
              partitions = config.partitions;
              # keep-sorted end
            };
          }
        )
      ];
    }).config.flake;
}
