{
  inputs = {
    # keep-sorted start block=yes
    nixpkgs-terraform-providers-bin = {
      url = "github:nix-community/nixpkgs-terraform-providers-bin";
      inputs.nixpkgs.follows = "rebmit/nixpkgs";
    };
    rebmit.url = ./../..;
    # keep-sorted end
  };

  outputs = _: { };
}
