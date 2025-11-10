{
  flake.unify.modules."security/rtkit" = {
    nixos = {
      module = _: {
        security.rtkit.enable = true;
      };
    };
  };
}
