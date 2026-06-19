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
        version = "2.11.4-unstable-2026-06-19";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "caddy";
          rev = "dcd7d1d3531db87dfa7f5cc59331d93b466cc76c";
          hash = "sha256-1+VOqKQs2nL08GuRlatZzCYGTOqwZDu1ZYnpEvGrhiw=";
        };
        vendorHash = "sha256-kWaQdKHNFYNp3a85axMCEw20sBLyxmAJs1Bp3Qu/rg0=";
        nixUpdateExtraArgs = [
          "--version=branch=master"
          "--override-filename"
          "pkgs/by-name/caddy/default.nix"
        ];
      };
    in
    final.callPackage (import ./package.nix packageArgs) { };
}
