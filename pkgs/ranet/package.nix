{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "ranet";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "NickCao";
    repo = "ranet";
    rev = "v${version}";
    sha256 = "sha256-xHdIuT/j35amoTjc4/s0uFFVLiM7BmLIEaZLGSa3QGU";
  };

  cargoLock = {
    lockFile = src + /Cargo.lock;
  };

  checkFlags = [
    "--skip=address::test::remote"
  ];

  meta = with lib; {
    description = "Redundant array of networks";
    homepage = "https://github.com/NickCao/ranet";
    license = licenses.mit;
  };
}
