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
      inherit (lib.attrsets)
        optionalAttrs
        getAttrFromPath
        nameValuePair
        listToAttrs
        ;
      inherit (lib.lists) foldl;
      inherit (lib.modules) mkDefault;
      inherit (lib.strings) splitString;
      inherit (lib.trivial) pipe;
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, partitionStack, ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        disabledModules = [ "${flake-parts}/all-modules.nix" ];

        imports = [
          # keep-sorted start block=yes
          "${flake-parts}/modules/flake.nix"
          "${flake-parts}/modules/moduleWithSystem.nix"
          "${flake-parts}/modules/perSystem.nix"
          "${flake-parts}/modules/transposition.nix"
          "${flake-parts}/modules/withSystem.nix"
          flake-parts.flakeModules.partitions
          # keep-sorted end
        ];

        transposition = mkDefault { };

        perSystem =
          { system, ... }:
          {
            _module.args.pkgs = mkDefault nixpkgs.legacyPackages.${system};
          };

        partitions = {
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
                  (partitionAttr "configs" "checks")
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
            nixosConfigurations = partitionAttr "configs" "nixosConfigurations";
            nixosModules = partitionAttr "modules" "nixosModules";
            overlays = partitionAttr "pkgs" "overlays";
            packages = partitionAttr "pkgs" "packages";
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
    );
}
