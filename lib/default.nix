{
  inputs ? import ../npins,
  lib ? import (inputs.nixpkgs + "/lib"),
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
