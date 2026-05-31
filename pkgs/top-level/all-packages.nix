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
        version = "2.19.0-unstable-2026-05-25";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "bird";
          rev = "cb83d86daae68ce4da0b36b3783fe820c5fb8e49";
          fetchSubmodules = false;
          hash = "sha256-lLjV9xAcusGBWomeCGL5yk9U9ZJMqzL4S+dwwL1t41s=";
        };
      };
    in
    final.callPackage ../by-name/bird2 { } source;

  bird3-rebmit =
    let
      source = {
        version = "3.3.0-unstable-2026-05-25";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "bird";
          rev = "13079fd3a067d6bfd8077a76d742d0e6d4ef2b46";
          fetchSubmodules = false;
          hash = "sha256-cPGkfKkvyXTZzQUc1pwNSBeat5j+DGOS2Rq2y9+i/Wc=";
        };
      };
    in
    final.callPackage ../by-name/bird3 { } source;

  caddy-rebmit =
    let
      source = {
        version = "2.11.3-unstable-2026-05-12";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "caddy";
          rev = "a0d859a2bb31e106090774811aca265d8a1be9a3";
          hash = "sha256-fHJs6FVrcPDm85TJogPLTwnKfdwMiS8WfCsWSkRh8/Q=";
        };
        vendorHash = "sha256-1w1Rr6fCQ49KdUkCL1UwItPWj32EGxe8PsTMF7KO+dk=";
      };
    in
    final.callPackage ../by-name/caddy { } source;

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
        version = "0.12.1-unstable-2026-05-08";
        src = fetchFromGitHub {
          owner = "Nheko-Reborn";
          repo = "nheko";
          rev = "90ff9c6f36dd9df9e0e23212c34b83ec61772bba";
          hash = "sha256-Zyvfxuk77FYBYwPJykK6YBnnCLG1BeN6jJ5gcDA5Go4=";
        };
      };
    in
    final.callPackage ../by-name/nheko { inherit mtxclient; } source;

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
