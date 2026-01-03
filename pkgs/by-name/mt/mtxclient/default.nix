let
  mtxclient =
    {
      lib,
      stdenv,
      cmake,
      pkg-config,
      coeurl,
      curl,
      libevent,
      nlohmann_json,
      olm,
      openssl,
      re2,
      spdlog,
      gtest,
      source,
    }:

    stdenv.mkDerivation (finalAttrs: {
      inherit (source) pname version src;

      patches = [
        ./remove-network-tests.patch
      ];

      cmakeFlags = [
        (lib.cmakeBool "BUILD_LIB_TESTS" finalAttrs.finalPackage.doCheck)
        (lib.cmakeBool "BUILD_LIB_EXAMPLES" false)
      ];

      nativeBuildInputs = [
        cmake
        pkg-config
      ];

      buildInputs = [
        coeurl
        curl
        libevent
        nlohmann_json
        olm
        openssl
        re2
        spdlog
      ];

      checkInputs = [ gtest ];

      doCheck = true;

      meta = {
        description = "Client API library for the Matrix protocol";
        homepage = "https://github.com/Nheko-Reborn/mtxclient";
        license = lib.licenses.mit;
        maintainers = with lib.maintainers; [ rebmit ];
        platforms = lib.platforms.all;
      };
    });
in
{
  scopes.default =
    { final, ... }:
    {
      mtxclient_latest =
        let
          source = {
            pname = "mtxclient";
            version = "0.10.1";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "Nheko-Reborn";
                repo = "mtxclient";
                rev = "v${source.version}";
                hash = "sha256-Y0FMCq4crSbm0tJtYq04ZFwWw+vlfxXKXBo0XUgf7hw=";
              }
            ) { };
          };
        in
        final.callPackage mtxclient { inherit source; };

      mtxclient_unstable =
        let
          source = {
            pname = "mtxclient";
            version = "0.10.1-unstable-2025-09-20";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "Nheko-Reborn";
                repo = "mtxclient";
                rev = "d6f10427d1c5e5b1a45f426274f8d2e8dd0b64be";
                hash = "sha256-zxpvRDKpp8sWSmf/xLgoHDWMzmdkQenZepXg+CoGtcg=";
              }
            ) { };
          };
        in
        final.callPackage mtxclient { inherit source; };
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) mtxclient mtxclient_latest mtxclient_unstable;
    };
}
