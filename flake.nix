{
  inputs = {
    # keep-sorted start block=yes
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dns = {
      url = "github:nix-community/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.gitignore.follows = "gitignore-nix";
      inputs.flake-compat.follows = "flake-compat";
    };
    gitignore-nix = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-terraform-providers-bin = {
      url = "github:nix-community/nixpkgs-terraform-providers-bin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:rebmit/nixpkgs";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      inherit (lib.modules) evalModules mkOptionDefault;
    in
    (evalModules {
      specialArgs = {
        inherit inputs self;
        flake-parts-lib = flake-parts.lib;
        moduleLocation = "${self.outPath}/flake.nix";
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
        # keep-sorted end

        {
          transposition = mkOptionDefault { };

          systems = [
            "x86_64-linux"
            "aarch64-linux"
            "aarch64-darwin"
          ];

          imports = [
            (import-tree ./dev)
            (import-tree ./lib)
            (import-tree ./modules/flake)
          ];
        }
      ];
    }).config.flake;
}
