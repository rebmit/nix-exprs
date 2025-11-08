{
  unify.modules."programs/git" = {
    nixos.module = _: {
      programs.git = {
        enable = true;
        lfs.enable = true;
      };
    };
  };
}
