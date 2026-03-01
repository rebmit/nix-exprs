{
  unify.profiles.system._.security._.rtkit =
    { ... }:
    {
      nixos =
        { ... }:
        {
          security.rtkit.enable = true;
        };
    };
}
