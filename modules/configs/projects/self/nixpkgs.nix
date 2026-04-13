{
  inputs,
  lib,
  __findFile,
  ...
}:

{
  includes = [ <rebmit/features/project/nixpkgs> ];

  modules.perTarget =
    { ... }:
    {
      nixpkgs = {
        config = {
          allowNonSource = false;
          allowNonSourcePredicate =
            pkg:
            lib.elem (lib.getName pkg) [
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
              "zulu-ca-jdk"
              # keep-sorted end
            ]
            || lib.elem lib.sourceTypes.binaryFirmware pkg.meta.sourceProvenance;
          allowInsecurePredicate =
            pkg:
            lib.elem (lib.getName pkg) [
              # keep-sorted start
              "olm"
              # keep-sorted end
            ];
        };

        overlays = [
          (final: prev: {
            inherit (import (inputs.nixpkgs-terraform-providers-bin + "/overlay.nix") final prev)
              terraform-providers-bin
              ;
            inherit (import inputs.nix-index-database { pkgs = final; })
              nix-index-with-db
              nix-index-with-small-db
              comma-with-db
              ;
          })
        ];
      };
    };
}
