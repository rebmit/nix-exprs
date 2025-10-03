{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) recursiveUpdate;
  inherit (lib.fixedPoints) makeExtensible;
  inherit (lib.lists) foldl;
  inherit (lib.options) mkOption;

  libModule =
    { config, ... }:
    {
      options.flake.lib = mkOption {
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

      config = {
        _module.args.selfLib = config.flake.lib;
      };
    };
in
{
  imports = [ libModule ];

  flake.modules.flake.lib = libModule;
}
