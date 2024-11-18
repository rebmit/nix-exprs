{ inputs, lib }:
let
  inherit (lib) makeExtensible;
  self = makeExtensible (
    self:
    let
      callLibs = file: import file { inherit inputs lib self; };
    in
    {
      path = callLibs ./path.nix;
    }
  );
in
self
