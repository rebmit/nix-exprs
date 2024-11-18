# Portions of this file are sourced from
# https://github.com/linyinfeng/dotfiles/tree/b618b0fd16fb9c79ab7199ed51c4c0f98a392cea/lib
{
  inputs,
  lib,
  ...
}:
let
  haumea = inputs.haumea.lib;

  rakeLeaves =
    src:
    haumea.load {
      inherit src;
      loader = haumea.loaders.path;
      transformer =
        _cursor: dir:
        if dir ? default then
          assert (lib.attrNames dir == [ "default" ]);
          dir.default
        else
          dir;
    };

  flattenTree =
    tree:
    let
      mkNewPrefix = prefix: name: "${if prefix == "" then "" else "${prefix}/"}${name}";
      flattenTree' =
        prefix: remain:
        if lib.isAttrs remain then
          lib.flatten (lib.mapAttrsToList (name: value: flattenTree' (mkNewPrefix prefix name) value) remain)
        else
          [ (lib.nameValuePair prefix remain) ];
    in
    lib.listToAttrs (flattenTree' "" tree);

  buildModuleList = dir: lib.attrValues (flattenTree (rakeLeaves dir));
in
{
  inherit rakeLeaves flattenTree buildModuleList;
}
