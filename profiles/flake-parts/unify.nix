# Portions of this file are sourced from
# https://codeberg.org/quasigod/unify/src/commit/860b5ac977988b57b4fca57e33ac0f4ef7b8af7f/modules/lib.nix (MIT License)
# https://codeberg.org/quasigod/unify/src/commit/860b5ac977988b57b4fca57e33ac0f4ef7b8af7f/modules/modules.nix (MIT License)
{
  self,
  config,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib.attrsets)
    mapAttrs
    getAttr
    filterAttrs
    attrNames
    hasAttr
    optionalAttrs
    ;
  inherit (lib.lists)
    elem
    head
    tail
    filter
    ;
  inherit (lib.options) mkOption;
  inherit (lib.trivial) pipe;
  inherit (lib.types)
    lazyAttrsOf
    submodule
    listOf
    str
    deferredModule
    ;
  inherit (self.lib.types) mkStructuredType;
  inherit (flake-parts-lib) mkSubmoduleOptions;

  supportedClass =
    class:
    elem class [
      "nixos"
      "darwin"
      "homeManager"
    ];

  modules = config.flake.unify.modules;

  collectRequiresClosure =
    class: names:
    let
      filteredModules = (filterAttrs (_: hasAttr class)) modules;

      iter =
        seen: pending:
        if pending == [ ] then
          seen
        else
          let
            name = head pending;
            rest = tail pending;
          in
          if elem name seen then
            iter seen rest
          else
            iter (seen ++ [ name ]) (filteredModules.${name}.${class}.meta.requires ++ rest);
    in
    iter [ ] names;

  collectModulesForConfig =
    class:
    {
      name ? null,
      includes ? [ ],
      excludes ? [ ],
    }:
    let
      getModules =
        f:
        pipe modules [
          (filterAttrs (_: hasAttr class))
          (mapAttrs (_: getAttr class))
          (filterAttrs f)
          attrNames
        ];

      names = getModules (_: v: elem name v.meta.configs) ++ includes;

      closure = pipe names [
        (collectRequiresClosure class)
        (filter (n: !elem n excludes))
      ];
    in
    closure;
in
{
  options.flake = mkSubmoduleOptions {
    unify.lib = mkOption {
      default = {
        inherit
          collectRequiresClosure
          collectModulesForConfig
          ;
      };
      readOnly = true;
      description = ''
        A set of helper functions for unify.
      '';
    };

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
                      configs = mkOption {
                        type = listOf str;
                        default = [ ];
                        description = ''
                          A list of configuration names.  If the current configuration name appears
                          in this list, this module will be automatically imported.
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
                  apply = mod: {
                    _class = name;
                    imports = [ mod ];
                  };
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
}
