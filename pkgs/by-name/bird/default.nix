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
        version = "2.19.1-unstable-2026-06-14";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "bird";
          rev = "48c352b4d6e5005eb97d22cd1df666bb1d833321";
          fetchSubmodules = false;
          hash = "sha256-Cj0EZAXLPydwcuFRyxYgfLVQMDCd282AwDif7lVmTeA=";
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
