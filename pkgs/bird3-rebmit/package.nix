{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  flex,
  bison,
  readline,
  libssh,
}:

stdenv.mkDerivation {
  pname = "bird";
  version = "3.1.3-unstable-2025-09-05";

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "bird";
    rev = "a22f9181831ad7b52dde7325f2129a9f07c772c2";
    fetchSubmodules = false;
    sha256 = "sha256-oadV5lVBMORJUZlnVe3kZ3Qh+SS2hSbJ/9VZr9lUqWU=";
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

  patches = [ ./dont-create-sysconfdir-2.patch ];

  CPP = "${stdenv.cc.targetPrefix}cpp -E";

  configureFlags = [
    "--localstatedir=/var"
    "--runstatedir=/run/bird"
  ];

  meta = {
    description = "BIRD Internet Routing Daemon";
    homepage = "http://bird.network.cz";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
