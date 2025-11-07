{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.fixedPoints) makeExtensible;
  inherit (lib.lists) foldl;
  inherit (lib.options) mkOption;
  inherit (flake-parts-lib) mkSubmoduleOptions;

  libModule = _: {
    options.flake = mkSubmoduleOptions {
      lib = mkOption {
        type = types.functionTo (types.attrsOf types.unspecified) // {
          merge =
            _loc: defs:
            let
              funcs = map (d: d.value) defs;
            in
            self: foldl (acc: f: recursiveUpdate acc (f self)) { } funcs;
        };
        default = _: { };
        apply = makeExtensible;
        description = ''
          An extensible set of library functions provided by the flake.
        '';
      };
    };
  };
in
{
  flake.flakeModules.lib = libModule;
}
