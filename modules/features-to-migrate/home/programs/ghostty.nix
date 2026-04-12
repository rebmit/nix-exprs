{
  unify.features.home._.programs._.ghostty =
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
              # keep-sorted start block=yes
              font-family = "monospace";
              font-size = 12;
              gtk-single-instance = true;
              macos-option-as-alt = true;
              theme = "light:Adwaita,dark:Adwaita Dark";
              # keep-sorted end
            };
          };
        };
    };
}
