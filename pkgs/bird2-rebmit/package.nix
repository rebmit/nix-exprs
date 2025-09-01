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
  version = "2.17.1-unstable-2025-09-01";

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "bird";
    rev = "a9c6ded5cdeef7c933af71aae2d95ea636679a95";
    fetchSubmodules = false;
    sha256 = "sha256-ThVqSUVJnson4W0ZpTOdBsTc/KNl1Q1a7BPb3cWdFYc=";
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
