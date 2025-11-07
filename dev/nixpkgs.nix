{ inputs, ... }:
{
  perSystem = {
    nixpkgs = {
      overlays = [ inputs.nixpkgs-terraform-providers-bin.overlay ];
    };
  };
}
