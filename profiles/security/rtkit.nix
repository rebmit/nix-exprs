{
  flake.unify.modules."security/rtkit" = {
    nixos = {
      module =
        { ... }:
        {
          security.rtkit.enable = true;
        };
    };
  };
}
