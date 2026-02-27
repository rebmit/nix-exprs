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

    stdenv.mkDerivation (_finalAttrs: {
      inherit (source) pname version src;

      patches = [
        ./fix-darwin-build.patch
      ];

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

      postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
        makeWrapper "$out/Applications/nheko.app/Contents/MacOS/nheko" "$out/bin/nheko"
      '';

      meta = {
        description = "Desktop client for the Matrix protocol";
        homepage = "https://github.com/Nheko-Reborn/nheko";
        license = lib.licenses.gpl3Plus;
        mainProgram = "nheko";
        maintainers = with lib.maintainers; [ rebmit ];
        platforms = lib.platforms.all;
      };
    });
in
{
  overlays.default =
    { final, ... }:
    {
      nheko_unstable =
        let
          mtxclient = final.mtxclient_unstable;

          source = {
            pname = "nheko";
            version = "0.12.1-unstable-2026-02-27";
            src = final.callPackage (
              { fetchFromGitHub }:
              fetchFromGitHub {
                owner = "Nheko-Reborn";
                repo = "nheko";
                rev = "8ec568c645ca20569b010dbbdb59b6953c1d5600";
                hash = "sha256-E8e9ccWD8DNdEkyOzf+b2kDtIVRBub+GEwlohwXleV0=";
              }
            ) { };
          };
        in
        final.callPackage nheko { inherit mtxclient source; };
    };

  checks =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) nheko_unstable;
      };
    };
}
