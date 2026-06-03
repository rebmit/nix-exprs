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
  caddy-rebmit =
    let
      packageArgs = {
        version = "2.11.4-unstable-2026-06-03";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "caddy";
          rev = "623c5f1f2f72a8155eb36e0a74af3d74d77d8db3";
          hash = "sha256-SOTYsjaILxNhoQwlve6ExoD7O9MAsIH1flbJzT34KVI=";
        };
        vendorHash = "sha256-Ymof5u4ECNQ4U7rKiCTdx2P/Q2HBHviNSj8+FocyS5k=";
        nixUpdateExtraArgs = [
          "--version=branch=master"
          "--override-filename"
          "pkgs/by-name/caddy/default.nix"
        ];
      };
    in
    final.callPackage (import ./package.nix packageArgs) { };
}
