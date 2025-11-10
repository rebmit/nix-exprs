{ inputs, ... }:
{
  perSystem = {
    nixpkgs = {
      config = {
        allowNonSource = true;
      };
      overlays = [
        inputs.nixpkgs-terraform-providers-bin.overlay
      ];
    };
  };
}
