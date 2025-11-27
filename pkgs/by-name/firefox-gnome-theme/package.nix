{
  perSystem =
    { prev, ... }:
    let
      firefox-gnome-theme =
        {
          lib,
          stdenvNoCC,
          fetchFromGitHub,
        }:

        stdenvNoCC.mkDerivation (finalAttrs: {
          pname = "firefox-gnome-theme";
          version = "143";

          src = fetchFromGitHub {
            owner = "rafaelmardojai";
            repo = "firefox-gnome-theme";
            rev = "v${finalAttrs.version}";
            fetchSubmodules = false;
            hash = "sha256-0E3TqvXAy81qeM/jZXWWOTZ14Hs1RT7o78UyZM+Jbr4=";
          };

          installPhase = ''
            mkdir -p $out/lib/firefox-gnome-theme
            cp -r theme configuration userChrome.css userContent.css $out/lib/firefox-gnome-theme
          '';

          meta = {
            description = "A GNOME theme for Firefox";
            homepage = "https://github.com/rafaelmardojai/firefox-gnome-theme";
            license = lib.licenses.unlicense;
            maintainers = with lib.maintainers; [ rebmit ];
            platforms = lib.platforms.all;
          };
        });
    in
    {
      packages.firefox-gnome-theme = prev.callPackage firefox-gnome-theme { };
    };
}
