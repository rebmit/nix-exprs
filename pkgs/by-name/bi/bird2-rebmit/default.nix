let
  bird2-rebmit =
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
      version = "2.17.3-unstable-2025-12-11";

      src = fetchFromGitHub {
        owner = "rebmit";
        repo = "bird";
        rev = "51d7d554adf7b0eb5febf091cb6488ab0b4425fe";
        fetchSubmodules = false;
        hash = "sha256-lA38pjV2/gqT5dXVGpcTiT82z1qEgCTUPolQaqswwUs=";
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
      bird2-rebmit = final.callPackage bird2-rebmit { };
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) bird2-rebmit;
    };
}
