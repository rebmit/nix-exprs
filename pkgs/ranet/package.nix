{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ranet";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "NickCao";
    repo = "ranet";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-xHdIuT/j35amoTjc4/s0uFFVLiM7BmLIEaZLGSa3QGU";
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
})
