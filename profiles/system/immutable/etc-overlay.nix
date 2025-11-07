{
  unify.modules."system/immutable" = {
    nixos.module = _: {
      system.etc.overlay = {
        enable = true;
        mutable = false;
      };
    };
  };
}
