{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.options) mkOption;

  flakeModulesModule =
    { moduleLocation, ... }:
    {
      _file = ./flake-modules.nix;

      options.flake.flakeModules = mkOption {
        type = types.lazyAttrsOf types.deferredModule;
        default = { };
        apply = mapAttrs (
          k: v: {
            _class = "flake";
            _file = "${toString moduleLocation}#flakeModules.${k}";
            # https://github.com/hercules-ci/flake-parts/pull/251
            key = "${toString moduleLocation}#flakeModules.${k}";
            imports = [ v ];
          }
        );
        description = ''
          flake-parts modules.
        '';
      };
    };
in
{
  imports = [ flakeModulesModule ];

  flake.flakeModules.flakeModules = flakeModulesModule;
}
