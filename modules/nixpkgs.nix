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
            # keep-sorted end
          ];
      };
    };
  };
}
