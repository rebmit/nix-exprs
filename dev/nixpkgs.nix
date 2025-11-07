{ inputs, self, ... }:
{
  imports = [ self.flakeModules.nixpkgs ];

  perSystem = {
    nixpkgs = {
      config = {
        allowNonSource = true;
      };
      overlays = [ inputs.nixpkgs-terraform-providers-bin.overlay ];
    };
  };
}
