let
  dnsmasq-china-list =
    {
      lib,
      stdenvNoCC,
      fetchFromGitHub,
    }:

    stdenvNoCC.mkDerivation {
      pname = "dnsmasq-china-list";
      version = "0-unstable-2025-12-30";

      src = fetchFromGitHub {
        owner = "felixonmars";
        repo = "dnsmasq-china-list";
        rev = "90e77e94e3184645cad516bc528717b624547917";
        fetchSubmodules = false;
        hash = "sha256-cHd7uoSUILbE61pQh2kAFIBC4zDaOLuM025NJbDu0OY=";
      };

      makeFlags = [ "raw" ];

      installPhase = ''
        install -Dm644 accelerated-domains.china.raw.txt $out/accelerated-domains.china.raw.txt
        install -Dm644 apple.china.raw.txt $out/apple.china.raw.txt
        install -Dm644 google.china.raw.txt $out/google.china.raw.txt
      '';

      meta = {
        description = "Chinese-specific configuration to improve your favorite DNS server";
        homepage = "https://github.com/felixonmars/dnsmasq-china-list";
        license = lib.licenses.wtfpl;
        maintainers = with lib.maintainers; [ rebmit ];
        platforms = lib.platforms.all;
      };
    };
in
{
  scopes.default =
    { final, ... }:
    {
      dnsmasq-china-list = final.callPackage dnsmasq-china-list { };
    };
}
