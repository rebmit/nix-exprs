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
  version = "3.3.2-unstable-2026-08-01";

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "bird";
    rev = "2245c2d151485700caf6af8a51940b08cbc835bc";
    fetchSubmodules = false;
    hash = "sha256-PGmrmlRwBkbYiq1M0QPQ4GtTOqn1qB/6S9DrIF4YP94=";
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
        "branch=unstable-v3"
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
