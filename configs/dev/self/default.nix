{
  devshell.enable = true;
  git-hooks.enable = true;

  treefmt = {
    enable = true;
    config.programs = {
      keep-sorted.enable = true;
      prettier.enable = true;
    };
  };

  languages = {
    nix.enable = true;
    shell.enable = true;
  };
}
