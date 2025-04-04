{ inputs, lib }:
let
  inherit (lib) makeExtensible;
  self = makeExtensible (
    self:
    let
      callLibs = file: import file { inherit inputs lib self; };
    in
    {
      misc = callLibs ./misc;
      network = callLibs ./network;
      path = callLibs ./path.nix;
    }
  );
in
self
