{ inputs, self, ... }:
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/checks.nix"
    "${inputs.flake-parts}/modules/nixosConfigurations.nix"
    # keep-sorted end
  ];

  perSystem =
    { system, ... }:
    {
      nixpkgs = self.partitions.pkgs.module.allSystems.${system}.nixpkgs;
    };
}
