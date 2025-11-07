{
  unify.modules."programs/fish" = {
    nixos.module = _: {
      programs.fish = {
        enable = true;
        useBabelfish = true;
      };
    };
  };
}
