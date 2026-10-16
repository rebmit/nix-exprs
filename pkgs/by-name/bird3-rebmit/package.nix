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
  version = "3.4.0-unstable-2026-10-16";

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "bird";
    rev = "a55482f994954fed683b27d27ad9990878a5c7ec";
    fetchSubmodules = false;
    hash = "sha256-SQxQHPnCK09ymtMUfpjDWw+4lcKnai0ib0q4iUTB4KQ=";
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
