{
  unify.features.system._.security._.rtkit =
    { ... }:
    {
      nixos =
        { ... }:
        {
          security.rtkit.enable = true;
        };
    };
}
