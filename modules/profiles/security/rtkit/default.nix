{
  unify.profiles.security._.rtkit = {
    nixos =
      { ... }:
      {
        security.rtkit.enable = true;
      };
  };
}
