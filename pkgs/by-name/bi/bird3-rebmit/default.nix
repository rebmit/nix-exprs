let
  bird3-rebmit =
    {
      lib,
      stdenv,
      autoreconfHook,
      flex,
      bison,
      readline,
      libssh,
      source,
    }:

    stdenv.mkDerivation {
      inherit (source) pname version src;

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
  scopes.default =
    { final, ... }:
    {
      bird3-rebmit = final.bird3-rebmit_latest;

      bird3-rebmit_latest =
        let
          source = {
            pname = "bird";
            version = "3.2.0-unstable-2026-01-04";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "rebmit";
                repo = "bird";
                rev = "aa77caf9f253c706aadd932761aa535759d3b892";
                fetchSubmodules = false;
                hash = "sha256-EF/N+uulYWb3Dw5MNbTPOIV/ANuxoh/Y3UIXmdScw3w=";
              }
            ) { };
          };
        in
        final.callPackage bird3-rebmit { inherit source; };
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) bird3-rebmit bird3-rebmit_latest;
    };
}
