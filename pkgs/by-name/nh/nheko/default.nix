let
  nheko =
    {
      lib,
      stdenv,
      cmake,
      asciidoc,
      pkg-config,
      cmark,
      coeurl,
      curl,
      kdsingleapplication,
      libevent,
      libsecret,
      lmdb,
      lmdbxx,
      mtxclient,
      nlohmann_json,
      olm,
      re2,
      spdlog,
      gst_all_1,
      libnice,
      qt6Packages,
      withVoipSupport ? stdenv.hostPlatform.isLinux,
      source,
    }:

    stdenv.mkDerivation {
      inherit (source) pname version src;

      patches = [
        ./fix-darwin-build.patch
      ]
      ++ (source.extraPatches or [ ]);

      nativeBuildInputs = [
        asciidoc
        cmake
        lmdbxx
        pkg-config
        qt6Packages.wrapQtAppsHook
      ];

      buildInputs = [
        cmark
        coeurl
        curl
        kdsingleapplication
        libevent
        libsecret
        lmdb
        mtxclient
        nlohmann_json
        olm
        qt6Packages.qtbase
        qt6Packages.qtdeclarative
        qt6Packages.qtimageformats
        qt6Packages.qtkeychain
        qt6Packages.qtmultimedia
        qt6Packages.qtsvg
        qt6Packages.qttools
        qt6Packages.qt-jdenticon
        re2
        spdlog
      ]
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        qt6Packages.qtwayland
      ]
      ++ lib.optionals withVoipSupport [
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        (gst_all_1.gst-plugins-good.override { qt6Support = true; })
        gst_all_1.gst-plugins-bad
        libnice
      ];

      cmakeFlags = [
        (lib.cmakeBool "VOIP" withVoipSupport)
      ];

      preFixup = ''
        # unset QT_STYLE_OVERRIDE to avoid showing a blank window when started
        # https://github.com/NixOS/nixpkgs/issues/333009
        qtWrapperArgs+=(--unset QT_STYLE_OVERRIDE)
      ''
      + lib.optionalString withVoipSupport ''
        # add gstreamer plugins path to the wrapper
        qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
      '';

      meta = {
        description = "Desktop client for the Matrix protocol";
        homepage = "https://github.com/Nheko-Reborn/nheko";
        license = lib.licenses.gpl3Plus;
        mainProgram = "nheko";
        maintainers = with lib.maintainers; [ rebmit ];
        platforms = lib.platforms.all;
      };
    };
in
{
  scopes.default =
    { final, ... }:
    {
      nheko_latest =
        let
          mtxclient = final.mtxclient_latest;

          source = {
            pname = "nheko";
            version = "0.12.1";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "Nheko-Reborn";
                repo = "nheko";
                rev = "v${source.version}";
                hash = "sha256-WlWxe4utRSc9Tt2FsnhBwxzQsoDML2hvm3g5zRnDEiU=";
              }
            ) { };
            extraPatches = final.callPackage (
              { fetchpatch }:
              [
                # Fixes rendering replies with QT 6.9.2
                (fetchpatch {
                  url = "https://github.com/Nheko-Reborn/nheko/commit/2769642d3c7bd3c0d830b2f18ef6b3bf6a710bf4.patch";
                  hash = "sha256-y8aiS6h5CSJYBdsAH4jYhAyrFug7aH2H8L6rBfULnQQ=";
                })
                # Fix for Qt 6.10
                (fetchpatch {
                  url = "https://github.com/Nheko-Reborn/nheko/commit/af2ca72030deb14a920a888e807dc732d93e3714.patch";
                  hash = "sha256-tlYrfEoUkdJoVzvfF34IhXdn1AxLO0MOlp9rzuFivws=";
                })
              ]
            ) { };
          };
        in
        final.callPackage nheko { inherit mtxclient source; };

      nheko_unstable =
        let
          mtxclient = final.mtxclient_unstable;

          source = {
            pname = "nheko";
            version = "0.12.1-unstable-2025-12-26";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "Nheko-Reborn";
                repo = "nheko";
                rev = "5b065f353c93725cd96c231d078fb742b1a5aa54";
                hash = "sha256-Rxg0aRiJuFyqa0ZcZcZoJmdHr4H69oEEQF6aoqh1VZg=";
              }
            ) { };
          };
        in
        final.callPackage nheko { inherit mtxclient source; };
    };

  checks =
    { pkgs, ... }:
    {
      inherit (pkgs) nheko nheko_latest nheko_unstable;
    };
}
