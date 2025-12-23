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
      ...
    }:
    let
      inherit (nixpkgs) lib;
      inherit (lib.modules) evalModules mkOptionDefault;
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
      ];
    }).config.flake;
}
