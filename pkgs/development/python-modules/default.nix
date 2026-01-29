{ config, lib, ... }:
let
  inherit (lib.attrsets) genAttrs;
  inherit (lib.fixedPoints) composeManyExtensions;
in
{
  overlays.default =
    { prev, ... }:
    genAttrs
      [
        "python310"
        "python311"
        "python312"
        "python313"
        "python314"
        "python315"
        "python3Minimal"
        "pypy27"
        "pypy310"
        "pypy311"
      ]
      (
        name:
        prev.${name}.override (prev: {
          packageOverrides = composeManyExtensions [
            (prev.packageOverrides or (_: _: { }))
            config.overlays.python
          ];
        })
      );
}
