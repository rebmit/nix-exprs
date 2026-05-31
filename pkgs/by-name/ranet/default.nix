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
  ranet =
    let
      packageArgs = {
        version = "0.13.0";
        src = fetchFromGitHub {
          owner = "NickCao";
          repo = "ranet";
          rev = "v${packageArgs.version}";
          hash = "sha256-XuB6nHOEkzZl/V48pGHvgmoPineEBFa8dI1yuXB9pTM=";
        };
        cargoHash = "sha256-qSjJaMpYKRZMkhjw0/8BVCjxgnTjBBhTtPPbhv38Ia4=";
        nixUpdateExtraArgs = [
          "--override-filename"
          "pkgs/by-name/ranet/default.nix"
        ];
      };
    in
    final.callPackage (import ./package.nix packageArgs) { };
}
