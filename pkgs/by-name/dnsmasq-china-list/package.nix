{
  perSystem =
    { prev, ... }:
    let
      dnsmasq-china-list =
        {
          lib,
          stdenvNoCC,
          fetchFromGitHub,
        }:

        stdenvNoCC.mkDerivation {
          pname = "dnsmasq-china-list";
          version = "0-unstable-2025-11-15";

          src = fetchFromGitHub {
            owner = "felixonmars";
            repo = "dnsmasq-china-list";
            rev = "ec8b5cb63e2e06e988e2522624cc73fefdb150f7";
            fetchSubmodules = false;
            sha256 = "sha256-swc6E6QQ9JIhQXNl1WKnmr1g42HzNyHW9vzyPjDnVqY=";
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
      packages.dnsmasq-china-list = prev.callPackage dnsmasq-china-list { };
    };
}
