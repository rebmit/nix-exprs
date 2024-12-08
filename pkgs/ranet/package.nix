{
  lib,
  rustPlatform,
  fetchFromGitHub,
  ...
}:

rustPlatform.buildRustPackage rec {
  pname = "ranet";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "NickCao";
    repo = "ranet";
    rev = "v${version}";
    sha256 = "sha256-GB8FXnHzaM06MivfpYEFFIp4q0WfH3a7+jmoC3Tpwbs=";
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
