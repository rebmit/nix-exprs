{
  lib ? (
    import (
      let
        lock = builtins.fromJSON (builtins.readFile ../flake.lock);
        nodeName = lock.nodes.root.inputs.nixpkgs;
      in
      fetchTree lock.nodes.${nodeName}.locked + "/lib"
    )
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
    }
  );
in
lib // { rebmit = selfLib; }
