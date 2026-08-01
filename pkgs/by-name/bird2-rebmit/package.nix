{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  flex,
  bison,
  readline,
  libssh,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bird";
  version = "2.19.2-unstable-2026-08-01";

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "bird";
    rev = "431800763298a30276eefd3e83d267064b256e0f";
    fetchSubmodules = false;
    hash = "sha256-mYI4D2AnsmptfJKfbiCRME6aQBL6EFKnKz33M1fN9G4=";
  };

  nativeBuildInputs = [
    autoreconfHook
    flex
    bison
  ];

  buildInputs = [
    readline
    libssh
  ];

  patches = [
    ./dont-create-sysconfdir-2.patch
  ];

  env.CPP = "${stdenv.cc.targetPrefix}cpp -E";

  configureFlags = [
    "--localstatedir=/var"
    "--runstatedir=/run/bird"
  ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch=unstable-v2"
        "--version-regex"
        "v(${lib.versions.major finalAttrs.version}\\..*)"
      ];
    };
  };

  meta = {
    description = "BIRD Internet Routing Daemon";
    homepage = "https://bird.nic.cz/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ rebmit ];
    platforms = lib.platforms.linux;
  };
})
