{
  flake.modules.nixos.immutable = _: {
    system.etc.overlay = {
      enable = true;
      mutable = false;
    };
  };
}
