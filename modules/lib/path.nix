# Portions of this file are sourced from
# https://github.com/nix-community/preservation/blob/93416f4614ad2dfed5b0dcf12f27e57d27a5ab11/lib.nix (MIT License)
{ lib, ... }:
let
  inherit (lib.lists)
    foldl'
    length
    sublist
    ;
  inherit (lib.strings)
    hasSuffix
    hasPrefix
    removeSuffix
    removePrefix
    substring
    splitString
    ;
in
{
  flake.lib =
    _:
    let
      concatTwoPaths =
        parent: child:
        if hasSuffix "/" parent then
          if hasPrefix "/" child then parent + (removePrefix "/" child) else parent + child
        else if hasPrefix "/" child then
          parent + child
        else
          parent + "/" + child;

      concatPaths = foldl' concatTwoPaths "";

      parentDirectory =
        path:
        assert "/" == (substring 0 1 path);
        let
          parts = splitString "/" (removeSuffix "/" path);
          len = length parts;
        in
        if len < 1 then "/" else concatPaths ([ "/" ] ++ (sublist 0 (len - 1) parts));
    in
    {
      path = {
        inherit
          concatTwoPaths
          concatPaths
          parentDirectory
          ;
      };
    };
}
