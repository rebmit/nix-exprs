{ self, ... }:
{
  imports = [
    # keep-sorted start
    self.flakeModules."unify/nixos"
    self.flakeModules.nixpkgs
    # keep-sorted end
  ];
}
