{ inputs, self, ... }:
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/checks.nix"
    "${inputs.flake-parts}/modules/nixosConfigurations.nix"
    self.flakeModules.meta
    self.flakeModules.nixpkgs
    # keep-sorted end
  ];

  meta = self.partitions.profiles.module.meta;

  perSystem =
    { system, ... }:
    {
      nixpkgs = self.partitions.profiles.module.allSystems.${system}.nixpkgs;
    };
}
