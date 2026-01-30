{
  unify.profiles.security._.sudo = {
    nixos =
      { ... }:
      {
        security.sudo.enable = false;

        security.sudo-rs = {
          enable = true;
          execWheelOnly = true;
          wheelNeedsPassword = true;
        };
      };
  };
}
