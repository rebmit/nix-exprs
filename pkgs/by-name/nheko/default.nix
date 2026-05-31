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
  nheko_unstable =
    let
      mtxclient = final.mtxclient_unstable;

      packageArgs = {
        version = "0.12.1-unstable-2026-05-08";
        src = fetchFromGitHub {
          owner = "Nheko-Reborn";
          repo = "nheko";
          rev = "90ff9c6f36dd9df9e0e23212c34b83ec61772bba";
          hash = "sha256-Zyvfxuk77FYBYwPJykK6YBnnCLG1BeN6jJ5gcDA5Go4=";
        };
        nixUpdateExtraArgs = [
          "--version=branch=master"
          "--override-filename"
          "pkgs/by-name/nheko/default.nix"
        ];
      };
    in
    final.callPackage (import ./package.nix packageArgs) { inherit mtxclient; };
}
