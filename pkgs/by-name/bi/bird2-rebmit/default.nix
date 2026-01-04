let
  bird2-rebmit =
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
        homepage = "https://bird.network.cz/";
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
      bird2-rebmit = final.bird2-rebmit_latest;

      bird2-rebmit_latest =
        let
          source = {
            pname = "bird";
            version = "2.18-unstable-2026-01-04";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "rebmit";
                repo = "bird";
                rev = "cb6f8414e25af797949529a09f1336e71e91b38e";
                fetchSubmodules = false;
                hash = "sha256-gcqj+YtNqqo/2365xEAq056KTazg/HfJVk1FJ+oGDLg=";
              }
            ) { };
          };
        in
        final.callPackage bird2-rebmit { inherit source; };
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) bird2-rebmit bird2-rebmit_latest;
    };
}
