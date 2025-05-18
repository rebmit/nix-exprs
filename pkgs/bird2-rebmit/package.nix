{
  lib,
  stdenv,
  fetchFromGitea,
  autoreconfHook,
  flex,
  bison,
  readline,
  libssh,
}:

stdenv.mkDerivation {
  pname = "bird";
  version = "2.17.1-unstable-2025-05-19";

  src = fetchFromGitea {
    domain = "git.rebmit.moe";
    owner = "rebmit";
    repo = "bird";
    rev = "cd5972bdb3ee5e75a833c552445578c98bafd416";
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

  meta = with lib; {
    description = "BIRD Internet Routing Daemon";
    homepage = "http://bird.network.cz";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
