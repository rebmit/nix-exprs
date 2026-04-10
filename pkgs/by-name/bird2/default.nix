{
  lib,
  stdenv,
  autoreconfHook,
  flex,
  bison,
  readline,
  libssh,
}:

{
  pname ? "bird",
  version,
  src,
}:

stdenv.mkDerivation {
  inherit pname version src;

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

  meta = {
    description = "BIRD Internet Routing Daemon";
    homepage = "https://bird.network.cz/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ rebmit ];
    platforms = lib.platforms.linux;
  };
}
