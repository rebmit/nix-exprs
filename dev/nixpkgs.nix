{ inputs, lib, ... }:
let
  inherit (lib.modules) mkOverride;
in
{
  perSystem = {
    nixpkgs = {
      config = {
        allowNonSource = mkOverride 75 true;
      };
      overlays = [ inputs.nixpkgs-terraform-providers-bin.overlay ];
    };
  };
}
