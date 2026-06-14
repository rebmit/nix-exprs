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
        version = "3.3.1-unstable-2026-06-14";
        src = fetchFromGitHub {
          owner = "rebmit";
          repo = "bird";
          rev = "2821995dc900bd1a86c1dc16266a710157a39584";
          fetchSubmodules = false;
          hash = "sha256-e3H9Y+KCpUULLXeNwEodJVaLhwdmJI3CwjIrG1VJ7BQ=";
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
