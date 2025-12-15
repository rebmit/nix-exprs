let
  ranet =
    {
      lib,
      rustPlatform,
      source,
    }:

    rustPlatform.buildRustPackage {
      inherit (source)
        pname
        version
        src
        cargoHash
        ;

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
    };
in
{
  overlays.default =
    { final, ... }:
    {
      ranet =
        let
          source = {
            pname = "ranet";
            version = "0.13.0";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "NickCao";
                repo = "ranet";
                rev = "v${source.version}";
                hash = "sha256-XuB6nHOEkzZl/V48pGHvgmoPineEBFa8dI1yuXB9pTM=";
              }
            ) { };
            cargoHash = "sha256-qSjJaMpYKRZMkhjw0/8BVCjxgnTjBBhTtPPbhv38Ia4=";
          };
        in
        final.callPackage ranet { inherit source; };
    };

  checks =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) ranet;
      };
    };
}
