{ inputs, config, ... }:
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/legacyPackages.nix"
    "${inputs.flake-parts}/modules/overlays.nix"
    # keep-sorted end
  ];

  perSystem =
    { system, pkgs, ... }:
    {
      _module.args.pkgs = inputs.nixpkgs.legacyPackages.${system}.extend config.flake.overlays.default;

      legacyPackages = pkgs;
    };
}
