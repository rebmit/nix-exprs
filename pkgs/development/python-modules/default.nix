{ config, lib, ... }:
let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.fixedPoints) composeManyExtensions;
in
{
  scopes.default =
    { prev, ... }:
    genAttrs
      [
        "python310"
        "python311"
        "python312"
        "python313"
        "python314"
        "python315"
        "pypy310"
        "pypy311"
      ]
      (
        name:
        prev.${name}.override (
          prev:
          prev
          // {
            packageOverrides = composeManyExtensions [
              (prev.packageOverrides or (_: _: { }))
              (_: config.scopes.python _)
            ];
          }
        )
      );
}
