{ self, lib, ... }:
let
  inherit (lib.lists) elem;
  inherit (lib.strings) getName;
in
{
  perSystem = {
    nixpkgs = {
      config = {
        allowNonSource = false;
      };
      overlays = [
        self.overlays.default

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
        allowNonSource =
          p:
          elem (getName p) [
            # keep-sorted start
            "cargo-bootstrap"
            "go"
            "rustc-bootstrap"
            "rustc-bootstrap-wrapper"
            "sof-firmware"
            # keep-sorted end
          ];
      };
    };
  };
}
