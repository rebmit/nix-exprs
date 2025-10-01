# Portions of this file are sourced from
# https://github.com/linyinfeng/dotfiles/tree/b618b0fd16fb9c79ab7199ed51c4c0f98a392cea/lib
{ lib, ... }:
let
  inherit (lib.attrsets)
    isAttrs
    mapAttrsToList
    nameValuePair
    listToAttrs
    ;
  inherit (lib.lists) flatten;
in
{
  flake.lib =
    _:
    let
      flattenTree =
        tree: recurseCond:
        let
          mkNewPrefix = prefix: name: "${if prefix == "" then "" else "${prefix}/"}${name}";
          flattenTree' =
            prefix: remain:
            if isAttrs remain && recurseCond remain then
              flatten (mapAttrsToList (name: value: flattenTree' (mkNewPrefix prefix name) value) remain)
            else
              [ (nameValuePair prefix remain) ];
        in
        listToAttrs (flattenTree' "" tree);
    in
    {
      attrsets = {
        inherit flattenTree;
      };
    };
}
