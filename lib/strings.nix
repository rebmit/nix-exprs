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
    { ... }:
    let
      concatPath =
        parent: child:
        if hasSuffix "/" parent then
          if hasPrefix "/" child then parent + (removePrefix "/" child) else parent + child
        else if hasPrefix "/" child then
          parent + child
        else
          parent + "/" + child;

      concatPaths = foldl' concatPath "";

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
      strings = {
        inherit
          concatPaths
          parentDirectory
          ;
      };
    };
}
