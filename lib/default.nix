{
  lib ? (
    let
      sources = import ../npins;
    in
    import (sources.nixpkgs + "/lib")
  ),
}:

let
  selfLib = lib.fix (
    self:
    let
      callLibs = file: import file { inherit self lib; };
    in
    {
      attrsets = callLibs ./attrsets.nix;
      modules = callLibs ./modules.nix;
      types = callLibs ./types.nix;
    }
  );
in
lib // { rebmit = selfLib; }
