# Portions of this file are sourced from
# https://codeberg.org/quasigod/unify/src/commit/860b5ac977988b57b4fca57e33ac0f4ef7b8af7f/modules/lib.nix (MIT License)
{ lib, flake-parts-lib, ... }:
let
  inherit (lib.attrsets)
    mapAttrs
    getAttr
    filterAttrs
    attrNames
    hasAttr
    ;
  inherit (lib.lists)
    elem
    head
    tail
    fold
    filter
    ;
  inherit (lib.options) mkOption;
  inherit (lib.trivial) pipe;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in
{
  flake.flakeModules."unify/lib" =
    { self, ... }:
    let
      modules = self.unify.modules;

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

      collectModulesForHost =
        class:
        {
          host ? null,
          tags ? [ ],
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

          names =
            (fold (tag: acc: getModules (_: v: elem tag v.meta.tags) ++ acc) [ ] tags)
            ++ getModules (_: v: elem host v.meta.hosts)
            ++ includes;

          closure = pipe names [
            (collectRequiresClosure "nixos")
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
              collectModulesForHost
              ;
          };
          readOnly = true;
          description = ''
            A set of helper functions for unify.
          '';
        };
      };
    };
}
