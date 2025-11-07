{
  inputs = {
    # nixpkgs

    nixpkgs.follows = "rebmit/nixpkgs";

    # flake modules

    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks-nix = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.gitignore.follows = "gitignore-nix";
      inputs.flake-compat.follows = "flake-compat";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # libraries

    gitignore-nix = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rebmit.url = ./../..;

    # programs

    nixpkgs-terraform-providers-bin = {
      url = "github:nix-community/nixpkgs-terraform-providers-bin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # misc

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = _: { };
}
