{ config, lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  options.scopes = mkOption {
    type = types.lazyAttrsOf (
      types.submodule (
        { extendModules, ... }:
        {
          freeformType = types.lazyAttrsOf types.raw;

          _module.args = {
            final = throw ''
              `final` is only defined when applying the scope as an overlay.
            '';
            prev = throw ''
              `prev` is only defined when applying the scope as an overlay.
            '';
          };

          __functor =
            _: final: prev:
            let
              eval = extendModules {
                specialArgs = { inherit final prev; };
              };
            in
            removeAttrs eval.config [ "__functor" ];
        }
      )
    );
  };

  config = {
    flake.overlays.default = _: config.scopes.default _;
  };
}
