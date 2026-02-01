{ self, ... }:
{
  unify.profiles.nix._.registry =
    { ... }:
    {
      nixos =
        { ... }:
        {
          nixpkgs.flake = {
            setFlakeRegistry = true;
            setNixPath = true;
          };

          nix.registry.p.flake = self;
        };
    };
}
