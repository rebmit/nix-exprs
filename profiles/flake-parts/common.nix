{ inputs, self, ... }:
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/checks.nix"
    self.flakeModules.meta
    self.flakeModules.nixpkgs
    # keep-sorted end
  ];

  perSystem =
    { system, ... }:
    {
      nixpkgs = self.partitions.pkgs.module.allSystems.${system}.nixpkgs;
    };
}
