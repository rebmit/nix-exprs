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
  scopes.default =
    { final, ... }:
    {
      ranet = final.ranet_latest;

      ranet_latest =
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

      ranet_unstable =
        let
          source = {
            pname = "ranet";
            version = "0.13.0-unstable-2025-12-18";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "NickCao";
                repo = "ranet";
                rev = "b0858a53f5728a400e42798bb2bc50f0daa6bb2e";
                hash = "sha256-hXHJroc9+jMMesSYwirz6cu/ZrpaSTfLW5X20aBzZgE=";
              }
            ) { };
            cargoHash = "sha256-arCICEHgnkQfw0ExqNUREqcECJVNy2iIyTSKwFL75aQ=";
          };
        in
        final.callPackage ranet { inherit source; };
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) ranet ranet_latest ranet_unstable;
    };
}
