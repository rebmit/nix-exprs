{ inputs, self, ... }:
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/checks.nix"
    "${inputs.flake-parts}/modules/legacyPackages.nix"
    self.flakeModules.nixpkgs
    # keep-sorted end
  ];
}
