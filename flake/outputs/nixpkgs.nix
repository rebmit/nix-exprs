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
        config = {
          allowUnfree = true;
        };
        inherit overlays;
      };
    };
}
