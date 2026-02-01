{ self, ... }:
{
  unify.profiles.nix._.registry =
    { ... }:
    {
      requires = [ "profiles/nix" ];

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
