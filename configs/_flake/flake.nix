{
  inputs = {
    # nixos modules

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };

    # darwin modules

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };

    # programs

    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
      inputs.nixpkgs-stable.follows = "rebmit/nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };

    # libraries

    rebmit.url = ./../..;
    flake-utils.url = "github:numtide/flake-utils";
    dns = {
      url = "github:nix-community/dns.nix";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = _: { };
}
