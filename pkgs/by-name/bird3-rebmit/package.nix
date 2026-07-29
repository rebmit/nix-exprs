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
  version = "3.3.1-unstable-2026-06-14";

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "bird";
    rev = "2821995dc900bd1a86c1dc16266a710157a39584";
    fetchSubmodules = false;
    hash = "sha256-e3H9Y+KCpUULLXeNwEodJVaLhwdmJI3CwjIrG1VJ7BQ=";
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
