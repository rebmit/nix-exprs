# Portions of this file are sourced from
# https://github.com/hercules-ci/flake-parts/blob/864599284fc7c0ba6357ed89ed5e2cd5040f0c04/extras/easyOverlay.nix (MIT License)
{
  inputs,
  lib,
  flake-parts-lib,
  getSystemIgnoreWarning,
  ...
}@toplevel:
let
  inherit (lib) types;
  inherit (lib.modules) mkForce;
  inherit (lib.options) mkOption;
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  options.perSystem = mkPerSystemOption (
    {
      extendModules,
      system,
      prev,
      ...
    }:
    {
      options.extendModules = mkOption {
        type = types.raw;
        default = extendModules;
        internal = true;
      };

      config = {
        _module.args = {
          prev = inputs.nixpkgs.legacyPackages.${system};
          final = prev.extend toplevel.config.flake.overlays.default;
        };
      };
    }
  );

  config = {
    flake.overlays.default =
      final: prev:
      let
        system = prev.stdenv.hostPlatform.system;
        perSys = (getSystemIgnoreWarning system).extendModules {
          modules = [
            {
              _module.args = {
                prev = mkForce prev;
                final = mkForce final;
              };
            }
          ];
        };
      in
      perSys.config.packages;
  };
}
