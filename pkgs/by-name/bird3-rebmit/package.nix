{
  perSystem =
    { prev, ... }:
    let
      bird3-rebmit =
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
          version = "3.1.4-unstable-2025-09-25";

          src = fetchFromGitHub {
            owner = "rebmit";
            repo = "bird";
            rev = "7c69e1b8e8c9cdea02e5deaa584a1bcaaa31b781";
            fetchSubmodules = false;
            sha256 = "sha256-3P515HfoQrHT7R8h3GeEaQmj1kxrzoA3wZlAreF531I=";
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
            homepage = "https://bird.nic.cz/";
            license = lib.licenses.gpl2Plus;
            maintainers = with lib.maintainers; [ rebmit ];
            platforms = lib.platforms.linux;
          };
        };
    in
    {
      packages.bird3-rebmit = prev.callPackage bird3-rebmit { };
    };
}
