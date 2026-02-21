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
  overlays.default =
    { final, ... }:
    {
      mtxclient_unstable =
        let
          source = {
            pname = "mtxclient";
            version = "0.10.1-unstable-2026-02-20";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "Nheko-Reborn";
                repo = "mtxclient";
                rev = "873911e352a0845dfb178f77b1ddea796a5d3455";
                hash = "sha256-kbS0Z0AuALf5I7OCqTF6snV5cX2HB1d16CB3agNtxCg=";
              }
            ) { };
          };
        in
        final.callPackage mtxclient { inherit source; };
    };

  checks =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) mtxclient_unstable;
      };
    };
}
