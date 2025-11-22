{ lib, ... }:
let
  inherit (lib.modules) mkForce;
  inherit (lib.strings) concatMapStringsSep;
in
{
  flake.unify.modules."misc/fontconfig" = {
    nixos = {
      module =
        { ... }:
        {
          fonts = {
            enableDefaultPackages = false;
            fontconfig.enable = true;
          };
        };
    };

    homeManager = {
      module =
        { pkgs, ... }:
        {
          fonts.fontconfig.enable = mkForce false;

          xdg.configFile."fontconfig/conf.d/10-hm-fonts.conf".text =
            let
              fonts = with pkgs; [
                noto-fonts
                noto-fonts-cjk-sans
                noto-fonts-cjk-serif
                noto-fonts-color-emoji
                iosevka
                nerd-fonts.symbols-only
              ];
              cache = pkgs.makeFontsCache {
                inherit (pkgs) fontconfig;
                fontDirectories = fonts;
              };
            in
            ''
              <?xml version='1.0'?>
              <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
              <fontconfig>
                ${concatMapStringsSep "\n" (font: "<dir>${font}</dir>") fonts}
                <cachedir>${cache}</cachedir>
              </fontconfig>
            '';

          xdg.configFile = {
            "fontconfig/conf.d/30-default-fonts.conf".source = ./home/30-default-fonts.conf;
            "fontconfig/conf.d/40-language-override.conf".source = ./home/40-language-override.conf;
          };
        };
    };
  };
}
