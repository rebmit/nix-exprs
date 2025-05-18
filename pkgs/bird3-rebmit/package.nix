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
  version = "3.1.1-unstable-2025-05-19";

  src = fetchFromGitea {
    domain = "git.rebmit.moe";
    owner = "rebmit";
    repo = "bird";
    rev = "b868af051ff4ef1c35bd1499c97e1ec1ddc797c8";
    fetchSubmodules = false;
    sha256 = "sha256-z7JmuqFS663+Gh+Z9DTu+rR5FWr4i/+UgUbY3mwbTDg=";
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
