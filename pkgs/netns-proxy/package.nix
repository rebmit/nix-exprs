{ rustPlatform, fetchFromGitHub, ... }:

rustPlatform.buildRustPackage rec {
  name = "netns-proxy";

  src = fetchFromGitHub {
    owner = "fooker";
    repo = "netns-proxy";
    rev = "6d9ccbfde4375cd614735ea5f6ee5aba2b6cfd2b";
    fetchSubmodules = false;
    sha256 = "sha256-N+my6cTuA7yNoYxocpRiLNcy7OwrJLvO2cGLJGv8a/I=";
  };

  cargoLock = {
    lockFile = src + /Cargo.lock;
  };
}
