{
  unify.profiles.programs._.ghostty._.user =
    { ... }:
    {
      homeManager =
        { pkgs, ... }:
        {
          programs.ghostty = {
            enable = true;
            package =
              if pkgs.stdenv.hostPlatform.isLinux then
                pkgs.ghostty
              else if pkgs.stdenv.hostPlatform.isDarwin then
                pkgs.ghostty-bin
              else
                null;
            settings = {
              font-family = "monospace";
              font-size = 12;
              theme = "light:Adwaita,dark:Adwaita Dark";
              gtk-single-instance = true;
            };
          };
        };
    };
}
