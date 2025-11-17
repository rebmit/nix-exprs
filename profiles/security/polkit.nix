{
  flake.unify.modules."security/polkit" = {
    nixos = {
      module =
        { ... }:
        {
          security.polkit.enable = true;
        };
    };
  };
}
