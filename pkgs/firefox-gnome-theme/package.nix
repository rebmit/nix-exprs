{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "firefox-gnome-theme";
  version = "142";

  src = fetchFromGitHub {
    owner = "rafaelmardojai";
    repo = "firefox-gnome-theme";
    rev = "v${finalAttrs.version}";
    fetchSubmodules = false;
    sha256 = "sha256-kyxuK5Fras7QYiJmUomqdq8NlgWV66hmNvxcJnGCpUE=";
  };

  installPhase = ''
    mkdir -p $out/lib/firefox-gnome-theme
    cp -r theme configuration userChrome.css userContent.css $out/lib/firefox-gnome-theme
  '';

  meta = {
    description = "A GNOME theme for Firefox";
    homepage = "https://github.com/rafaelmardojai/firefox-gnome-theme";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.all;
  };
})
