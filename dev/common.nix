{ inputs, self, ... }:
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/checks.nix"
    "${inputs.flake-parts}/modules/devShells.nix"
    "${inputs.flake-parts}/modules/formatter.nix"
    inputs.devshell.flakeModule
    inputs.git-hooks-nix.flakeModule
    inputs.treefmt-nix.flakeModule
    self.flakeModules.nixpkgs
    # keep-sorted end
  ];
}
