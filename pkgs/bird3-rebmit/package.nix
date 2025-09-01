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
  version = "3.1.2-unstable-2025-09-01";

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "bird";
    rev = "5ccd20076529492ff39698bee1a0d0776a90bc53";
    fetchSubmodules = false;
    sha256 = "sha256-9e7JDkza4wvEAt3zpdkBJvsoGb9u3iMOPyU8m/5MIWE=";
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
