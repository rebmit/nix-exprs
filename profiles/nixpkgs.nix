{ self, lib, ... }:
let
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
            profiles.packages = {
              inherit (pkgs) caddy-rebmit fuzzel mautrix-telegram;
              qt6Packages = { inherit (pkgs.qt6Packages) fcitx5-with-addons; };
            };
          };

      nixpkgs = {
        overlays = mkOrder 700 [
          (_final: prev: {
            caddy-rebmit = prev.caddy.withPlugins {
              plugins = [ "github.com/mholt/caddy-l4@v0.0.0-20250829174953-ad3e83c51edb" ];
              hash = "sha256-jZGQ9CgXMzaGXuLaOajvIc8tbuVdks/SMegAobIeKhQ=";
            };
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
