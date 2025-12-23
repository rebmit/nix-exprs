{ inputs, ... }:
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/checks.nix"
    # keep-sorted end
  ];

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = inputs.nixpkgs.legacyPackages.${system};
    };
}
