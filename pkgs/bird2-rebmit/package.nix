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
  version = "2.17-unstable-2025-05-07";

  src = fetchFromGitea {
    domain = "git.rebmit.moe";
    owner = "rebmit";
    repo = "bird";
    rev = "b418d68d5464788d4436379be0f347b25feb4d37";
    fetchSubmodules = false;
    sha256 = "sha256-rJBzAViCvoHiJQDYu2Tlkr8XTaR2YAL/aniAxMeBwhk=";
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
