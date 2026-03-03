{
  inputs = {
    # keep-sorted start block=yes
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };
    nixpkgs-20260227-56b28f2.url = "github:rebmit/nixpkgs/20260227.56b28f2";
    nixpkgs-terraform-providers-bin = {
      url = "github:nix-community/nixpkgs-terraform-providers-bin";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };
    rebmit.url = ./../..;
    # keep-sorted end
  };

  outputs = _: { };
}
