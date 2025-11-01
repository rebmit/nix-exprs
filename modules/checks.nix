{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib.attrsets) isDerivation;
  inherit (selfLib.attrsets) flattenTree;
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
