{
  perSystem =
    { pkgs, ... }:
    let
      dnsmasq-china-list =
        {
          lib,
          stdenvNoCC,
          fetchFromGitHub,
        }:

        stdenvNoCC.mkDerivation {
          pname = "dnsmasq-china-list";
          version = "0-unstable-2025-10-26";

          src = fetchFromGitHub {
            owner = "felixonmars";
            repo = "dnsmasq-china-list";
            rev = "b524f7faa31c43359eab372c80870581508124a1";
            fetchSubmodules = false;
            sha256 = "sha256-31uV1m2m4ExbiIwsXfIzH35mgidn0QAuTdAWA7m+EJY=";
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
      packages.dnsmasq-china-list = pkgs.callPackage dnsmasq-china-list { };
    };
}
