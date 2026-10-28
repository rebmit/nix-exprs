{ inputs, lib, ... }:

{
  perTarget =
    { ... }:
    {
      nixpkgs = {
        config = {
          allowNonSource = false;
          allowNonSourcePredicate =
            pkg:
            lib.elem (lib.getName pkg) [
              # keep-sorted start
              "cargo-bootstrap"
              "ghc-binary"
              "go"
              "librusty_v8"
              "rustc-bootstrap"
              "rustc-bootstrap-wrapper"
              "temurin-bin"
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
            inherit (inputs.nix-index-database.overlays.nix-index final prev)
              nix-index-with-db
              nix-index-with-small-db
              comma-with-db
              ;
          })
        ];
      };
    };
}
