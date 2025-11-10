{ inputs, self, ... }:
{
  imports = [
    # keep-sorted start
    inputs.devshell.flakeModule
    inputs.git-hooks-nix.flakeModule
    inputs.treefmt-nix.flakeModule
    self.flakeModules.meta
    self.flakeModules.nixpkgs
    self.flakeModules.unify
    # keep-sorted end
  ];
}
