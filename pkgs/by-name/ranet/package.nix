{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ranet";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "NickCao";
    repo = "ranet";
    rev = "v${finalAttrs.version}";
    hash = "sha256-U9445WUb7yZIqwsmemiyVZ0LCWuqB2Ohz9jtyQ1gQoM=";
  };

  cargoHash = "sha256-KginksEfr0Be7knoYpuLW+i07VCrb19aVIvUDOUNh5M=";

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
})
