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
  mtxclient_unstable =
    let
      packageArgs = {
        version = "0.10.1-unstable-2026-03-02";
        src = fetchFromGitHub {
          owner = "Nheko-Reborn";
          repo = "mtxclient";
          rev = "f5766cb53c244a808b7e512c7b83b3942fb67834";
          hash = "sha256-5LapoeXRiRi4tSpFvcVu4Z6+aDIz43UBoDU1Rx2y8TA=";
        };
        nixUpdateExtraArgs = [
          "--version=branch=master"
          "--override-filename"
          "pkgs/by-name/mtxclient/default.nix"
        ];
      };
    in
    final.callPackage (import ./package.nix packageArgs) { };
}
