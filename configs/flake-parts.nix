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

  # inherit from parent
  flake = {
    inherit (self) meta;
  };

  # TODO: fixup
  # perSystem =
  #   { ... }:
  #   {
  #     nixpkgs = self.partitions.profiles.module.allSystems.${system}.nixpkgs;
  #   };
}
