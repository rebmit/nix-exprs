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
      version = "3.1.5-unstable-2025-12-11";

      src = fetchFromGitHub {
        owner = "rebmit";
        repo = "bird";
        rev = "86fbd43a8d27b2a6d4c0aca0ab61adb570a6d0b5";
        fetchSubmodules = false;
        hash = "sha256-wP3brdKNWLNBnnzmnSEQ53xYnGiq3LkHB34o38875cw=";
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
  scopes.default =
    { final, ... }:
    {
      bird3-rebmit = final.callPackage bird3-rebmit { };
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) bird3-rebmit;
    };
}
