# Portions of this file are sourced from
# https://github.com/linyinfeng/dotfiles/blob/7b5cb693088c2996418d44a3f1203680762ed97d/lib/flatten-tree.nix (MIT License)
# https://github.com/linyinfeng/dotfiles/blob/7b5cb693088c2996418d44a3f1203680762ed97d/lib/transpose-attrs.nix (MIT License)
{ lib, ... }:
let
  inherit (lib.attrsets)
    isAttrs
    mapAttrsToList
    nameValuePair
    listToAttrs
    attrsToList
    recursiveUpdate
    ;
  inherit (lib.lists) flatten foldr;
in
{
  lib =
    { ... }:
    let
      flattenTree =
        settings: tree:
        let
          mkNewPrefix = prefix: name: "${if prefix == "" then "" else "${prefix}/"}${name}";
          flattenTree' =
            {
              leafFilter ? _: true,
              setFilter ? _: true,
            }:
            prefix: remain:
            if isAttrs remain && setFilter remain then
              flatten (mapAttrsToList (name: value: flattenTree' settings (mkNewPrefix prefix name) value) remain)
            else if leafFilter remain then
              [ (nameValuePair prefix remain) ]
            else
              [ ];
        in
        listToAttrs (flattenTree' settings "" tree);

      transposeAttrs =
        attrs:
        let
          list = foldr (sys: l: map (pair: pair // { system = sys.name; }) (attrsToList sys.value) ++ l) [ ] (
            attrsToList attrs
          );
        in
        foldr (
          item: transposed: recursiveUpdate transposed { ${item.name}.${item.system} = item.value; }
        ) { } list;
    in
    {
      attrsets = {
        inherit
          flattenTree
          transposeAttrs
          ;
      };
    };
}
