{
  unify.profiles.security._.polkit = {
    nixos =
      { ... }:
      {
        security.polkit.enable = true;
      };
  };
}
