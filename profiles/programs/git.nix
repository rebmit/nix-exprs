{
  unify.modules."programs/git" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
      };
    };

    nixos.module = _: {
      programs.git = {
        enable = true;
        lfs.enable = true;
      };
    };
  };
}
