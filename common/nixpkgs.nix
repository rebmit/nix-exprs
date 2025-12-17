{ self, lib, ... }:
let
  inherit (lib) sourceTypes;
  inherit (lib.attrsets) isDerivation;
  inherit (lib.lists) elem;
  inherit (lib.modules) mkOrder;
  inherit (lib.strings) getName;
  inherit (self.lib.attrsets) flattenTree;
in
{
  perSystem =
    { pkgs, ... }:
    {
      checks =
        flattenTree
          {
            setFilter = s: !isDerivation s;
            leafFilter = isDerivation;
          }
          {
            packages = {
              inherit (pkgs) fuzzel mautrix-telegram;
              qt6Packages = { inherit (pkgs.qt6Packages) fcitx5-with-addons; };
            };
          };

      nixpkgs = {
        config = {
          allowNonSource = false;
        };
        overlays = mkOrder 600 [
          self.overlays.default

          (_final: prev: {
            fuzzel = prev.fuzzel.override {
              svgBackend = "librsvg";
            };
            mautrix-telegram = prev.mautrix-telegram.overrideAttrs (oldAttrs: {
              patches = (oldAttrs.patches or [ ]) ++ [
                (prev.fetchpatch2 {
                  name = "mautrix-telegram-sticker";
                  url = "https://github.com/mautrix/telegram/pull/991/commits/0c2764e3194fb4b029598c575945060019bad236.patch";
                  hash = "sha256-48QiKByX/XKDoaLPTbsi4rrlu9GwZM26/GoJ12RA2qE=";
                })
              ];
            });
            qt6Packages = prev.qt6Packages.overrideScope (
              _final': prev': {
                fcitx5-with-addons = prev'.fcitx5-with-addons.override { libsForQt5.fcitx5-qt = null; };
              }
            );
          })
        ];
        predicates = {
          allowNonSource =
            p:
            elem (getName p) [
              # keep-sorted start
              "ant"
              "cargo-bootstrap"
              "dart"
              "ghc-binary"
              "go"
              "gradle"
              "librusty_v8"
              "rustc-bootstrap"
              "rustc-bootstrap-wrapper"
              "temurin-bin"
              # keep-sorted end
            ]
            || elem sourceTypes.binaryFirmware p.meta.sourceProvenance;
          allowInsecure =
            p:
            elem (getName p) [
              # keep-sorted start
              "olm"
              # keep-sorted end
            ];
        };
      };
    };
}
