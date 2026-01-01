let
  ranet =
    {
      lib,
      rustPlatform,
      fetchFromGitHub,
    }:

    rustPlatform.buildRustPackage (finalAttrs: {
      pname = "ranet";
      version = "0.13.0";

      src = fetchFromGitHub {
        owner = "NickCao";
        repo = "ranet";
        rev = "v${finalAttrs.version}";
        hash = "sha256-XuB6nHOEkzZl/V48pGHvgmoPineEBFa8dI1yuXB9pTM=";
      };

      cargoHash = "sha256-qSjJaMpYKRZMkhjw0/8BVCjxgnTjBBhTtPPbhv38Ia4=";

      checkFlags = [
        "--skip=address::test::remote"
      ];

      meta = {
        description = "Redundant array of networks";
        homepage = "https://github.com/NickCao/ranet";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ rebmit ];
        platforms = lib.platforms.linux;
      };
    });
in
{
  scopes.default =
    { final, ... }:
    {
      ranet = final.callPackage ranet { };
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) ranet;
    };
}
