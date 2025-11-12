{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.trivial) pipe;
  inherit (self.lib.attrsets) transposeAttrs;
in
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/checks.nix"
    "${inputs.flake-parts}/modules/legacyPackages.nix"
    inputs.flake-parts.flakeModules.modules
    self.flakeModules."unify/lib"
    self.flakeModules."unify/modules"
    self.flakeModules.meta
    self.flakeModules.nixpkgs
    # keep-sorted end
  ];

  flake.modules = pipe self.unify.modules [
    (mapAttrs (_: classes: mapAttrs (_: cfg: cfg.module) classes))
    transposeAttrs
  ];
}
