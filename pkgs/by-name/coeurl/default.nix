let
  coeurl =
    {
      lib,
      stdenv,
      ninja,
      pkg-config,
      meson,
      libevent,
      curl,
      spdlog,
      source,
    }:

    stdenv.mkDerivation {
      inherit (source) pname version src;

      nativeBuildInputs = [
        ninja
        pkg-config
        meson
      ];

      buildInputs = [
        libevent
        curl
        spdlog
      ];

      meta = {
        description = "Simple async wrapper around CURL for C++";
        homepage = "https://nheko.im/nheko-reborn/coeurl";
        license = lib.licenses.mit;
        platforms = lib.platforms.all;
        maintainers = with lib.maintainers; [ rebmit ];
      };
    };
in
{
  overlays.default =
    { final, ... }:
    {
      coeurl_unstable =
        let
          source = {
            pname = "coeurl";
            version = "0.3.2-unstable-2026-02-28";
            src = final.callPackage (
              { fetchFromGitLab }:
              fetchFromGitLab {
                domain = "nheko.im";
                owner = "nheko-reborn";
                repo = "coeurl";
                rev = "1c3a9029581a08749874226b68bb40c196ed21bb";
                hash = "sha256-8BwyPfLgkJG1CHnRAKxgn8ObEGSK+lKKUhQibs1dCg4=";
              }
            ) { };
          };
        in
        final.callPackage coeurl { inherit source; };
    };

  checks =
    { pkgs, ... }:
    {
      packages = {
        inherit (pkgs) coeurl_unstable;
      };
    };
}
