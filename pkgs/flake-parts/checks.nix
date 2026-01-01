{
  self,
  config,
  lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) isDerivation;
  inherit (lib.options) mkOption;
  inherit (self.lib.attrsets) flattenTree;
in
{
  options.checks = mkOption {
    type = types.submodule (
      { extendModules, ... }:
      {
        freeformType = types.lazyAttrsOf types.raw;

        _module.args = {
          pkgs = throw ''
            `pkgs` is only available when evaluating checks with a Nixpkgs package set.
          '';
        };

        __functor =
          _: pkgs:
          let
            eval = extendModules {
              specialArgs = { inherit pkgs; };
            };
          in
          removeAttrs eval.config [ "__functor" ];
      }
    );
    default = { };
    description = ''
      Checks defined as modules and evaluated with a Nixpkgs package set.
    '';
  };

  config = {
    perSystem =
      { pkgs, ... }:
      {
        checks = flattenTree {
          setFilter = s: !isDerivation s;
          leafFilter = isDerivation;
        } { packages = config.checks pkgs; };
      };
  };
}
