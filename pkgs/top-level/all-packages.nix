final: prev:

let
  inherit
    (final.callPackage (
      {
        fetchFromGitHub,
      }@args:
      args
    ) { })
    fetchFromGitHub
    ;
in
{
  # keep-sorted start block=yes newline_separated=yes
  bird2-rebmit =
    let
      source = {
        version = "2.18.1-unstable-2026-04-19";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "bird";
          rev = "e5c717fcaebb543572e15be2f1882d8cda9eca41";
          fetchSubmodules = false;
          hash = "sha256-NRF0JtOJgJ3A8VSlK9hly+0tM+3jJNsY4CkKJv1iP10=";
        };
      };
    in
    final.callPackage ../by-name/bird2 { } source;

  bird3-rebmit =
    let
      source = {
        version = "3.2.0-unstable-2026-01-04";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "bird";
          rev = "aa77caf9f253c706aadd932761aa535759d3b892";
          fetchSubmodules = false;
          hash = "sha256-EF/N+uulYWb3Dw5MNbTPOIV/ANuxoh/Y3UIXmdScw3w=";
        };
      };
    in
    final.callPackage ../by-name/bird3 { } source;

  caddy-rebmit =
    let
      source = {
        version = "2.11.2-unstable-2026-03-19";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "caddy";
          rev = "1a36552bf7218409c98caaf4f6b00cd7e0a10f2e";
          hash = "sha256-8R+x9Ym2/vjGpl1xbrgVGrsE/Z59Yz4ZggrF6OkpnBQ=";
        };
        vendorHash = "sha256-Zerl+Pa1bnM2I/p3HQzA8TRgzVxE6O/5/qJhI3J+TZc=";
      };
    in
    final.callPackage ../by-name/caddy { } source;

  canokey-manager =
    let
      source = {
        version = "5.4.0-unstable-2025-03-26";
        src = fetchFromGitHub {
          owner = "canokeys";
          repo = "yubikey-manager";
          rev = "088ab31778d94a5447b4ffa98529d4dafde618f1";
          hash = "sha256-fqrMCF1PSOaQ9K4eFGs9w6wjUGuHp+GwO/PBFh6xKSM=";
        };
      };
    in
    final.callPackage ../by-name/canokey-manager { } source;

  canokey-udev-rules = final.callPackage ../by-name/canokey-udev-rules { } { };

  mtxclient_unstable =
    let
      source = {
        version = "0.10.1-unstable-2026-03-02";
        src = fetchFromGitHub {
          owner = "Nheko-Reborn";
          repo = "mtxclient";
          rev = "f5766cb53c244a808b7e512c7b83b3942fb67834";
          hash = "sha256-5LapoeXRiRi4tSpFvcVu4Z6+aDIz43UBoDU1Rx2y8TA=";
        };
      };
    in
    final.callPackage ../by-name/mtxclient { } source;

  nheko_unstable =
    let
      mtxclient = final.mtxclient_unstable;

      source = {
        version = "0.12.1-unstable-2026-04-07";
        src = fetchFromGitHub {
          owner = "Nheko-Reborn";
          repo = "nheko";
          rev = "84d3d9a354b175bfcddfcf24ec9f74b350758059";
          hash = "sha256-GCH6VneFfx0UPw5TlWK4j6HRu70VAWmGcFo+lYatj1w=";
        };
      };
    in
    final.callPackage ../by-name/nheko { inherit mtxclient; } source;

  pythonPackagesExtensions = (prev.pythonPackagesExtensions or [ ]) ++ [
    (import ./python-packages.nix)
  ];

  ranet =
    let
      source = {
        version = "0.13.0";
        src = fetchFromGitHub {
          owner = "NickCao";
          repo = "ranet";
          rev = "v${source.version}";
          hash = "sha256-XuB6nHOEkzZl/V48pGHvgmoPineEBFa8dI1yuXB9pTM=";
        };
        cargoHash = "sha256-qSjJaMpYKRZMkhjw0/8BVCjxgnTjBBhTtPPbhv38Ia4=";
      };
    in
    final.callPackage ../by-name/ranet { } source;
  # keep-sorted end
}
