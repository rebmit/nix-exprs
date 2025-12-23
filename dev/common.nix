{ inputs, ... }:
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/checks.nix"
    "${inputs.flake-parts}/modules/devShells.nix"
    "${inputs.flake-parts}/modules/formatter.nix"
    inputs.devshell.flakeModule
    inputs.git-hooks-nix.flakeModule
    inputs.treefmt-nix.flakeModule
    # keep-sorted end
  ];

  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = inputs.nixpkgs.legacyPackages.${system};
    };
}
