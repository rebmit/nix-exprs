{ inputs, self, ... }:
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/nixosConfigurations.nix"
    self.flakeModules."unify/nixos"
    # keep-sorted end
  ];

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = self.legacyPackages.${system};
    };
}
