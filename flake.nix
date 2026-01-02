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
      self,
      flake-parts,
      nixpkgs,
      import-tree,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      inherit (lib.attrsets)
        optionalAttrs
        getAttrFromPath
        nameValuePair
        listToAttrs
        ;
      inherit (lib.lists) foldl;
      inherit (lib.modules) evalModules mkOptionDefault;
      inherit (lib.strings) splitString;
      inherit (lib.trivial) pipe;
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
        "${flake-parts}/modules/flake.nix"
        "${flake-parts}/modules/moduleWithSystem.nix"
        "${flake-parts}/modules/perSystem.nix"
        "${flake-parts}/modules/transposition.nix"
        "${flake-parts}/modules/withSystem.nix"
        flake-parts.flakeModules.partitions
        # keep-sorted end

        (
          { config, partitionStack, ... }:
          {
            transposition = mkOptionDefault { };

            systems = [
              "x86_64-linux"
              "aarch64-linux"
              "aarch64-darwin"
            ];

            partitions = optionalAttrs (partitionStack == [ ]) {
              # keep-sorted start block=yes
              configs = {
                extraInputsFlake = ./configs/_flake;
                module = import-tree ./configs;
              };
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
                  partition: attrPath:
                  (getAttrFromPath (splitString "/" attrPath) config.partitions.${partition}.module.flake);
              in
              {
                # keep-sorted start block=yes
                checks =
                  foldl
                    (
                      acc: v:
                      pipe config.systems [
                        (map (system: nameValuePair system (acc.${system} or { } // v.${system} or { })))
                        listToAttrs
                      ]
                    )
                    { }
                    [
                      # keep-sorted start
                      (partitionAttr "configs" "checks")
                      (partitionAttr "modules" "checks")
                      (partitionAttr "pkgs" "checks")
                      (partitionAttr "profiles" "checks")
                      # keep-sorted end
                    ];
                devShells = partitionAttr "dev" "devShells";
                flakeModules = partitionAttr "modules" "flakeModules";
                formatter = partitionAttr "dev" "formatter";
                legacyPackages = partitionAttr "pkgs" "legacyPackages";
                lib = partitionAttr "lib" "lib";
                nixosConfigurations = partitionAttr "configs" "nixosConfigurations";
                nixosModules = partitionAttr "modules" "nixosModules";
                overlays = partitionAttr "pkgs" "overlays";
                partitions = config.partitions;
                unify = {
                  # keep-sorted start block=yes
                  configs = partitionAttr "configs" "unify/configs";
                  lib = partitionAttr "profiles" "unify/lib";
                  modules = partitionAttr "profiles" "unify/modules";
                  # keep-sorted end
                };
                # keep-sorted end
              }
            );
          }
        )
      ];
    }).config.flake;
}
