{
  perSystem =
    { pkgs, ... }:
    let
      firefox-gnome-theme =
        {
          lib,
          stdenvNoCC,
          fetchFromGitHub,
        }:

        stdenvNoCC.mkDerivation {
          pname = "firefox-gnome-theme";
          version = "142-unstable-2025-09-17";

          src = fetchFromGitHub {
            owner = "rafaelmardojai";
            repo = "firefox-gnome-theme";
            rev = "0909cfe4a2af8d358ad13b20246a350e14c2473d";
            fetchSubmodules = false;
            sha256 = "sha256-lizRM2pj6PHrR25yimjyFn04OS4wcdbc38DCdBVa2rk=";
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
        };
    in
    {
      packages.firefox-gnome-theme = pkgs.callPackage firefox-gnome-theme { };
    };
}
