{ self, ... }:
let
  overlays = [
    self.overlays.default
  ];
in
{
  perSystem =
    { ... }:
    {
      nixpkgs = {
        inherit overlays;
      };
    };
}
