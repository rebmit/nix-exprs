{ inputs, self, ... }:
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/checks.nix"
    "${inputs.flake-parts}/modules/nixosConfigurations.nix"
    self.flakeModules.meta
    # keep-sorted end
  ];

  # inherit from parent
  flake = {
    inherit (self) meta;
  };

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = self.legacyPackages.${system};
    };
}
