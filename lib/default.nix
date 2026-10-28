{
  # Nixpkgs source tree to be imported.
  source ? (import ../inputs.nix).nixpkgs,

  # Nixpkgs library used to construct this library set.
  lib ? source.lib,
}:

let
  selfLib = lib.fix (
    self:
    let
      callLibs = file: import file { inherit self lib; };
    in
    {
      evalModules = callLibs ./eval-modules.nix;
    }
  );
in
lib // { rebmit = selfLib; }
