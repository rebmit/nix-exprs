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
  flake.lib =
    { ... }:
    let
      # https://github.com/linyinfeng/dotfiles/blob/5607d1c31434f33d9a8c2909fc694b9b4e4b5557/lib/flatten-tree.nix
      flattenTree =
        settings: tree:
        let
          mkNewPrefix =
            prefix: name:
            { separator, mapper }:
            "${if prefix == "" then "" else "${prefix}${separator}"}${mapper name}";

          flattenTree' =
            {
              leafFilter ? _: true,
              setFilter ? _: true,
              separator ? "/",
              mapper ? x: x,
            }:
            prefix: remain:
            if isAttrs remain && setFilter remain then
              flatten (
                mapAttrsToList (
                  name: value: flattenTree' settings (mkNewPrefix prefix name { inherit separator mapper; }) value
                ) remain
              )
            else if leafFilter remain then
              [ (nameValuePair prefix remain) ]
            else
              [ ];
        in
        listToAttrs (flattenTree' settings "" tree);

      # https://github.com/linyinfeng/dotfiles/blob/5607d1c31434f33d9a8c2909fc694b9b4e4b5557/lib/transpose-attrs.nix
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
