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
        version = "2.11.3-unstable-2026-05-12";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "caddy";
          rev = "a0d859a2bb31e106090774811aca265d8a1be9a3";
          hash = "sha256-fHJs6FVrcPDm85TJogPLTwnKfdwMiS8WfCsWSkRh8/Q=";
        };
        vendorHash = "sha256-1w1Rr6fCQ49KdUkCL1UwItPWj32EGxe8PsTMF7KO+dk=";
        nixUpdateExtraArgs = [
          "--version=branch=master"
          "--override-filename"
          "pkgs/by-name/caddy/default.nix"
        ];
      };
    in
    final.callPackage (import ./package.nix packageArgs) { };
}
