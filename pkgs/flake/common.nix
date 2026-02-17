{
  inputs,
  self,
  config,
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
    self.flakeModules.checks
    self.flakeModules.nixpkgs
    self.flakeModules.overlays
    # keep-sorted end
  ];

  overlays.internal =
    { final, prev, ... }:
    {
      inherit (inputs.nixpkgs-terraform-providers-bin.overlay final prev) terraform-providers-bin;
      inherit (inputs.nix-index-database.overlays.nix-index final prev)
        nix-index-with-db
        nix-index-with-small-db
        comma-with-db
        ;
    };

  perSystem =
    { pkgs, ... }:
    {
      nixpkgs = {
        config = {
          allowNonSource = false;
        };
        overlays = mkOrder 600 [
          config.overlays.default
          config.overlays.internal
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
              "ghostty-bin"
              "go"
              "gradle"
              "librusty_v8"
              "rustc-bootstrap"
              "rustc-bootstrap-wrapper"
              "temurin-bin"
              "utm"
              "zotero"
              "zulu-ca-jdk"
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
