{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ranet";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "NickCao";
    repo = "ranet";
    rev = "v${finalAttrs.version}";
    hash = "sha256-WqoGIK0bIBgOFd8EkfiwGxDdEQhXdxxfup1ObIuK/c0=";
  };

  cargoHash = "sha256-9egoV3yUgpmP5rajWJWAp5uy4zG+/zGzKsS72eyT4EI=";

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
