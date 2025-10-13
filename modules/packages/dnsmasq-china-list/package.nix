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
          version = "0-unstable-2025-10-13";

          src = fetchFromGitHub {
            owner = "felixonmars";
            repo = "dnsmasq-china-list";
            rev = "22dacefa3550ac19b30da5ad30a4f3749e86a482";
            fetchSubmodules = false;
            sha256 = "sha256-V4Us9dkm08EeSJ0l5JcsEpxFeGkeUpsf9KuelvD9hUs=";
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
