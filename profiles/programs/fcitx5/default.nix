{
  flake.unify.modules."programs/fcitx5" = {
    homeManager = {
      module =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            (qt6Packages.fcitx5-with-addons.override {
              addons = [
                qt6Packages.fcitx5-chinese-addons
                fcitx5-pinyin-zhwiki
              ];
              withConfigtool = false;
            })
          ];

          xdg.configFile."fcitx5" = {
            source = ./_config;
            force = true;
            recursive = true;
          };
        };
    };
  };
}
