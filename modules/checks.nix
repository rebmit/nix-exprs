{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib.attrsets) hasAttr;
  inherit (selfLib.attrsets) flattenTree;
in
{
  perSystem =
    { config, ... }:
    {
      checks = flattenTree {
        inherit (config) packages;
      } (v: !hasAttr "type" v || v.type != "derivation");
    };
}
