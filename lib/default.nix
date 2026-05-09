{
  # Path to the Nixpkgs source tree to be imported.
  path ? (import ../../npins).nixpkgs,

  # Nixpkgs library used to construct this library set.
  lib ? import (path + "/lib"),
}:

let
  selfLib = lib.fix (
    self:
    let
      callLibs = file: import file { inherit self lib; };
    in
    {
      # often used, or depending on very little
      trivial = callLibs ./trivial.nix;

      # module system
      modules = callLibs ./modules.nix;
      types = callLibs ./types.nix;
    }
  );
in
lib // { rebmit = selfLib; }
