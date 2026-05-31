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
  bird2-rebmit =
    let
      packageArgs = {
        version = "2.19.0-unstable-2026-05-25";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "bird";
          rev = "cb83d86daae68ce4da0b36b3783fe820c5fb8e49";
          fetchSubmodules = false;
          hash = "sha256-lLjV9xAcusGBWomeCGL5yk9U9ZJMqzL4S+dwwL1t41s=";
        };
        nixUpdateExtraArgs = [
          "--version=branch=unstable-v2"
          "--override-filename"
          "pkgs/by-name/bird/default.nix"
        ];
      };
    in
    final.callPackage (import ./package.nix packageArgs) { };

  bird3-rebmit =
    let
      packageArgs = {
        version = "3.3.0-unstable-2026-05-25";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "bird";
          rev = "13079fd3a067d6bfd8077a76d742d0e6d4ef2b46";
          fetchSubmodules = false;
          hash = "sha256-cPGkfKkvyXTZzQUc1pwNSBeat5j+DGOS2Rq2y9+i/Wc=";
        };
        nixUpdateExtraArgs = [
          "--version=branch=unstable-v3"
          "--override-filename"
          "pkgs/by-name/bird/default.nix"
        ];
      };
    in
    final.callPackage (import ./package.nix packageArgs) { };
}
