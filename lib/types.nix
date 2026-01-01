# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/f2636ab9403a72c98264ffd2f550b5a6e17b95e0/pkgs/pkgs-lib/formats.nix (MIT License)
{ lib, ... }:
let
  inherit (lib.types)
    oneOf
    bool
    int
    float
    str
    path
    attrsOf
    listOf
    nullOr
    ;
in
{
  lib =
    { ... }:
    let
      mkStructuredType =
        {
          typeName,
          nullable ? true,
        }:
        let
          baseType = oneOf [
            bool
            int
            float
            str
            path
            (attrsOf valueType)
            (listOf valueType)
          ];
          valueType = (if nullable then nullOr baseType else baseType) // {
            description = "${typeName} value";
          };
        in
        valueType;
    in
    {
      types = {
        inherit mkStructuredType;
      };
    };
}
