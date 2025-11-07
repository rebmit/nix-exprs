# Portions of this file are sourced from
# https://codeberg.org/quasigod/unify/src/commit/860b5ac977988b57b4fca57e33ac0f4ef7b8af7f/modules/lib.nix (MIT License)
{ lib, ... }:
let
  inherit (lib.attrsets)
    mapAttrs
    getAttr
    filterAttrs
    attrNames
    ;
  inherit (lib.lists) elem head tail;
  inherit (lib.options) mkOption;
  inherit (lib.trivial) pipe;

  collectModulesForTag =
    class: tag: modules:
    pipe modules [
      (mapAttrs (_: getAttr class))
      (filterAttrs (_: v: elem tag v.meta.tags))
      attrNames
    ];

  collectModulesForHost =
    class: host: modules:
    pipe modules [
      (mapAttrs (_: getAttr class))
      (filterAttrs (_: v: elem host v.meta.hosts))
      attrNames
    ];

  collectRequiresClosure =
    class: names: modules:
    let
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
            iter (seen ++ [ name ]) (modules.${name}.${class}.meta.requires ++ rest);
    in
    iter [ ] names;
in
{
  flake.flakeModules.unify = _: {
    options.unify.lib = mkOption {
      default = {
        inherit
          collectModulesForTag
          collectModulesForHost
          collectRequiresClosure
          ;
      };
      readOnly = true;
      description = ''
        A set of helper functions for unify.
      '';
    };
  };
}
