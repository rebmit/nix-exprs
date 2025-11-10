# Portions of this file are sourced from
# https://codeberg.org/quasigod/unify/src/commit/860b5ac977988b57b4fca57e33ac0f4ef7b8af7f/modules/modules.nix (MIT License)
{
  self,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs mapAttrs;
  inherit (lib.lists) elem any;
  inherit (lib.options) mkOption;
  inherit (lib.types)
    lazyAttrsOf
    submodule
    listOf
    str
    deferredModule
    ;
  inherit (lib.trivial) pipe warnIf;
  inherit (self.lib.attrsets) transposeAttrs;
  inherit (self.lib.types) mkStructuredType;
  inherit (flake-parts-lib) mkSubmoduleOptions;

  supportedClass =
    class:
    elem class [
      "nixos"
      "darwin"
      "homeManager"
    ];
in
{
  flake.flakeModules.unify =
    { config, ... }:
    {
      options.flake = mkSubmoduleOptions {
        unify.modules = mkOption {
          type = lazyAttrsOf (
            lazyAttrsOf (
              submodule (
                { name, ... }:
                {
                  options = {
                    meta = mkOption {
                      type = submodule {
                        freeformType = mkStructuredType { typeName = "meta"; };
                        options = optionalAttrs (supportedClass name) {
                          hosts = mkOption {
                            type = listOf str;
                            default = [ ];
                            description = ''
                              A list of host names.  If the current host name appears in this list, this
                              module will be automatically imported.
                            '';
                          };
                          tags = mkOption {
                            type = listOf str;
                            default = [ ];
                            description = ''
                              A list of host tags.  If any tag of the current configuration name matches
                              one in this list, this module will be automatically imported.
                            '';
                          };
                          requires = mkOption {
                            type = listOf str;
                            default = [ ];
                            description = ''
                              A list of module names that are required by this module.  When this module
                              is imported, all modules listed here will also be automatically imported.
                            '';
                          };
                          conflicts = mkOption {
                            type = listOf str;
                            default = [ ];
                            description = ''
                              A list of module names that conflict with this module.  If this module is
                              imported, any conflicting modules must not be imported.
                            '';
                          };
                        };
                      };
                      default = { };
                      description = ''
                        Metadata for this module.
                      '';
                    };
                    module = mkOption {
                      type = deferredModule;
                      default = { };
                      description = ''
                        The deferred module for this module.
                      '';
                    };
                  };
                }
              )
            )
          );
          default = { };
          description = ''
            Groups of modules unified under a common name.
          '';
        };
      };

      config = {
        flake.modules = pipe config.flake.unify.modules [
          (mapAttrs (
            name: classes:
            mapAttrs (
              class: cfg:
              let
                closure = config.flake.unify.lib.collectRequiresClosure class [ name ] config.flake.unify.modules;
              in
              warnIf (supportedClass class && (any (n: elem n closure) cfg.meta.conflicts))
                "requires closure of config.flake.unify.modules.${name}.${class} includes conflicting modules declared in meta.conflicts"
                cfg.module
            ) classes
          ))
          transposeAttrs
        ];
      };
    };
}
