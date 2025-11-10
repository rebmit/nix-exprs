{ inputs, self, ... }:
{
  imports = [
    # keep-sorted start
    inputs.devshell.flakeModule
    inputs.git-hooks-nix.flakeModule
    inputs.treefmt-nix.flakeModule
    self.flakeModules.nixpkgs
    # keep-sorted end
  ];
}
