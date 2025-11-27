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
          version = "0-unstable-2025-11-23";

          src = fetchFromGitHub {
            owner = "felixonmars";
            repo = "dnsmasq-china-list";
            rev = "a4036bc84ab76850b8bb8a53742899b24bb6c0de";
            fetchSubmodules = false;
            hash = "sha256-j6KqpDpcpY2pK907KeGEA7REt9/ZmwgmISqIWlMu9iY=";
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
