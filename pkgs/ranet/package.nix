{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "ranet";
  version = "0.12.0-unstable-2025-09-22";

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "ranet";
    rev = "32ba9d976d807a954d1981a4f9f6aedec09081dc";
    sha256 = "sha256-1p42aLmA9rzJBz8TQ59ectLHJbiiYBgYUHb+ljEYKQM=";
  };

  cargoHash = "sha256-Qd7Hy/Mq2XihTB7RHQYjRKjaM5eigLxL+MpVyUmBozk=";

  checkFlags = [
    "--skip=address::test::remote"
  ];

  meta = {
    description = "Redundant array of networks";
    homepage = "https://github.com/NickCao/ranet";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
