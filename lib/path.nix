# Portions of this file are sourced from
# https://github.com/linyinfeng/dotfiles/tree/b618b0fd16fb9c79ab7199ed51c4c0f98a392cea/lib
# https://github.com/spikespaz/bird-nix-lib/blob/3f44018dde966a00193081470f85a59458916986/lib/scaffold.nix
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

  scanPaths =
    path: keep:
    let
      inherit (lib) types;
      pred =
        if keep == null then
          (_: _: true)
        else if types.singleLineStr.check keep then
          (name: _: !(name == keep))
        else if lib.isFunction keep then
          keep
        else if (types.listOf types.singleLineStr).check keep then
          (name: _: !(builtins.elem name keep))
        else
          throw "importDir predicate should be a string, function, or list of strings";
      isNix =
        name: type:
        (type == "regular" && lib.hasSuffix ".nix" name)
        || (lib.pathIsRegularFile "${path}/${name}/default.nix");
      pred' = name: type: (isNix name type) && (pred name type);
    in
    map (name: path + "/${name}") (builtins.attrNames (lib.filterAttrs pred' (builtins.readDir path)));
in
{
  inherit
    rakeLeaves
    flattenTree
    buildModuleList
    scanPaths
    ;
}
