# Portions of this file are sourced from
# https://codeberg.org/quasigod/unify/src/commit/860b5ac977988b57b4fca57e33ac0f4ef7b8af7f/modules/modules.nix (MIT License)
{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.options) mkOption;
  inherit (lib.types)
    lazyAttrsOf
    submodule
    listOf
    deferredModule
    ;
  inherit (selfLib.attrsets) transposeAttrs;
  inherit (selfLib.types) mkStructuredType;

  unifyModule =
    { config, ... }:
    {
      options.unify.modules = mkOption {
        type = lazyAttrsOf (
          lazyAttrsOf (submodule {
            options = {
              meta = mkOption {
                type = submodule {
                  freeformType = mkStructuredType { typeName = "meta"; };
                };
                default = { };
                description = ''
                  Metadata for this module class.
                '';
              };
              modules = mkOption {
                type = listOf deferredModule;
                default = [ ];
                description = ''
                  A list of deferred modules that constitute this module for the given class.
                '';
              };
            };
          })
        );
        default = { };
        description = ''
          Groups of modules unified under a common name.
        '';
      };

      config = {
        flake.modules = transposeAttrs (
          mapAttrs (
            _: classes:
            mapAttrs (_: config: {
              imports = config.modules;
            }) classes
          ) config.unify.modules
        );
      };
    };
in
{
  flake.flakeModules.unify = unifyModule;
}
