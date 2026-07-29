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
  version = "2.19.1-unstable-2026-06-14";

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "bird";
    rev = "48c352b4d6e5005eb97d22cd1df666bb1d833321";
    fetchSubmodules = false;
    hash = "sha256-Cj0EZAXLPydwcuFRyxYgfLVQMDCd282AwDif7lVmTeA=";
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
