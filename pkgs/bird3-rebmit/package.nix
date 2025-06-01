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
  version = "3.1.2-unstable-2025-06-01";

  src = fetchFromGitea {
    domain = "git.rebmit.moe";
    owner = "rebmit";
    repo = "bird";
    rev = "ca39c8b879e0cc290848b4c73b499eced2805c53";
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

  meta = with lib; {
    description = "BIRD Internet Routing Daemon";
    homepage = "http://bird.network.cz";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
