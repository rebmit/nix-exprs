{
  inputs = {
    # keep-sorted start block=yes
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };
    dns = {
      url = "github:nix-community/dns.nix";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };
    rebmit.url = ./../..;
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };
    # keep-sorted end
  };

  outputs = _: { };
}
