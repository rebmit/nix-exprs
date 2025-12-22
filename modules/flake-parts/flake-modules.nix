# Portions of this file are sourced from
# https://github.com/hercules-ci/flake-parts/blob/864599284fc7c0ba6357ed89ed5e2cd5040f0c04/extras/flakeModules.nix (MIT License)
{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.options) mkOption;
  inherit (flake-parts-lib) mkSubmoduleOptions;

  flakeModulesModule =
    { moduleLocation, ... }:
    {
      options.flake = mkSubmoduleOptions {
        flakeModules = mkOption {
          type = types.lazyAttrsOf types.deferredModule;
          default = { };
          apply = mapAttrs (
            k: v: {
              _class = "flake";
              _file = "${toString moduleLocation}#flakeModules.${k}";
              key = "${toString moduleLocation}#flakeModules.${k}";
              imports = [ v ];
            }
          );
          description = ''
            flake-parts modules for use by other flakes.

            You can not read this option in defining the flake's own `imports`. Instead, you can
            put the module in question into its own file or let binding and reference
            it both in `imports` and export it with this option.

            See [Dogfood a Reusable Module](../dogfood-a-reusable-module.md) for details and an example.
          '';
        };
      };
    };
in
{
  imports = [ flakeModulesModule ];

  flake.flakeModules.flakeModules = flakeModulesModule;
}
