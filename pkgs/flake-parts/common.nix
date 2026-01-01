{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (lib) sourceTypes;
  inherit (lib.lists) elem;
  inherit (lib.modules) mkOrder;
  inherit (lib.strings) getName;
in
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/checks.nix"
    "${inputs.flake-parts}/modules/legacyPackages.nix"
    "${inputs.flake-parts}/modules/overlays.nix"
    self.flakeModules.nixpkgs
    # keep-sorted end
  ];

  perSystem =
    { pkgs, ... }:
    {
      nixpkgs = {
        config = {
          allowNonSource = false;
        };
        overlays = mkOrder 600 [ self.overlays.default ];
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

      legacyPackages = pkgs;
    };
}
