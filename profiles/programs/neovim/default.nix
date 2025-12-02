{
  flake.unify.modules."programs/neovim" = {
    nixos = {
      module =
        { ... }:
        {
          programs.nano.enable = false;

          programs.neovim = {
            enable = true;
            defaultEditor = true;
            withRuby = false;
            withPython3 = true;
            withNodeJs = false;
          };
        };
    };
  };
}
