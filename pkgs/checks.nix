{ self, lib, ... }:
let
  inherit (lib.attrsets) isDerivation;
  inherit (self.lib.attrsets) flattenTree;
in
{
  perSystem =
    { self', ... }:
    {
      checks = flattenTree {
        setFilter = s: !isDerivation s;
      } { inherit (self') packages; };
    };
}
