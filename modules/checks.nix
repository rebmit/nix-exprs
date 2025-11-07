{ self, lib, ... }:
let
  inherit (lib.attrsets) isDerivation;
  inherit (self.lib.attrsets) flattenTree;
in
{
  perSystem =
    { config, ... }:
    {
      checks = flattenTree {
        setFilter = s: !isDerivation s;
      } { inherit (config) packages; };
    };
}
