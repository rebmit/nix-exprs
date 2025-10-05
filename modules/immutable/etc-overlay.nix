{
  flake.modules.nixos.immutable = {
    system.etc.overlay = {
      enable = true;
      mutable = false;
    };
  };
}
