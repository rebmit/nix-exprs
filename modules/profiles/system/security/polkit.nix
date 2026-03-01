{
  unify.profiles.system._.security._.polkit =
    { ... }:
    {
      nixos =
        { ... }:
        {
          security.polkit.enable = true;
        };
    };
}
