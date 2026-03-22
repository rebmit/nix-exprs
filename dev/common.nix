{
  inputs,
  self,
  config,
  lib,
  getSystem,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) genAttrs;
  inherit (lib.modules) mkMerge mkForce;
in
{
  imports = [
    # keep-sorted start
    inputs.devshell.flakeModule
    inputs.git-hooks-nix.flakeModule
    inputs.treefmt-nix.flakeModule
    self.flakeModules.nixpkgs
    # keep-sorted end
  ];

  flake = {
    formatter = genAttrs config.systems (system: (getSystem system).formatter);
    devShells = genAttrs config.systems (system: (getSystem system).devShells);
  };

  perSystem =
    { system, ... }:
    {
      freeformType = types.lazyAttrsOf types.raw;

      config.nixpkgs = mkMerge [
        self.partitions.pkgs.module.allSystems.${system}.nixpkgs
        { config.allowNonSource = mkForce true; }
      ];
    };
}
