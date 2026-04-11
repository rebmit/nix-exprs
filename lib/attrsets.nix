{ lib, ... }:

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
        if builtins.isAttrs remain && setFilter remain then
          lib.flatten (
            lib.mapAttrsToList (
              name: value: flattenTree' settings (mkNewPrefix prefix name { inherit separator mapper; }) value
            ) remain
          )
        else if leafFilter remain then
          [ (lib.nameValuePair prefix remain) ]
        else
          [ ];
    in
    lib.listToAttrs (flattenTree' settings "" tree);

  # https://github.com/linyinfeng/dotfiles/blob/5607d1c31434f33d9a8c2909fc694b9b4e4b5557/lib/transpose-attrs.nix
  transposeAttrs =
    attrs:
    let
      list = lib.foldr (
        sys: l: map (pair: pair // { system = sys.name; }) (lib.attrsToList sys.value) ++ l
      ) [ ] (lib.attrsToList attrs);
    in
    lib.foldr (
      item: transposed: lib.recursiveUpdate transposed { ${item.name}.${item.system} = item.value; }
    ) { } list;
in
{
  inherit
    flattenTree
    transposeAttrs
    ;
}
