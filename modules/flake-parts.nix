{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  disabledModules = [
    "${inputs.flake-parts}/modules/apps.nix"
    "${inputs.flake-parts}/modules/legacyPackages.nix"
    "${inputs.flake-parts}/modules/nixosConfigurations.nix"
  ];
}
