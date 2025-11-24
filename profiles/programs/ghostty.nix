{
  flake.unify.modules."programs/ghostty" = {
    homeManager = {
      meta = {
        requires = [ "misc/theme/common" ];
      };

      module =
        { config, ... }:
        {
          programs.ghostty = {
            enable = true;
            settings = {
              font-family = "monospace";
              font-size = 12;
              theme = "light:${config.theme.light.ghosttyTheme},dark:${config.theme.dark.ghosttyTheme}";
              gtk-single-instance = true;
            };
          };
        };
    };
  };
}
