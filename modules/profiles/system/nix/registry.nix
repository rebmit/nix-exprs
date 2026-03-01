{ self, ... }:
{
  unify.profiles.system._.nix._.registry =
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

      darwin =
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
