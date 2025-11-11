{ self, ... }:
{
  imports = [
    # keep-sorted start
    self.flakeModules."unify/nixos"
    # keep-sorted end
  ];

  perSystem =
    { self', ... }:
    {
      _module.args.pkgs = self'.legacyPackages;
    };
}
