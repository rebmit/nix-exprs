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
  version = "2.17.2-unstable-2025-09-05";

  src = fetchFromGitHub {
    owner = "rebmit";
    repo = "bird";
    rev = "d4a738200d05248f29450da13eca632805d5eff3";
    fetchSubmodules = false;
    sha256 = "sha256-tZqsoOwSC/dpt0augQf6qLS6CuL2CIIvrtzrmmxcSg4=";
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
