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
  version = "3.1.0-unstable-2025-04-29";

  src = fetchFromGitea {
    domain = "git.rebmit.moe";
    owner = "rebmit";
    repo = "bird";
    rev = "75f1a9e63ff1d8ae282db59e721d77928e745373";
    fetchSubmodules = false;
    sha256 = "sha256-MIA/6xf4+iLfFvXrMJdiop/oVs/JrJcnBmxa3N+bLMQ=";
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
