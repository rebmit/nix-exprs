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

          options.__functor = mkOption {
            internal = true;
            visible = false;
            readOnly = true;
            default =
              _: final: prev:
              let
                eval = extendModules {
                  specialArgs = { inherit final prev; };
                };
              in
              removeAttrs eval.config [ "__functor" ];
            description = ''
              Functor used to evaluate the scope as a Nixpkgs overlay.
            '';
          };

          config._module.args = {
            final = throw ''
              `final` is only defined when applying the scope as an overlay.
            '';
            prev = throw ''
              `prev` is only defined when applying the scope as an overlay.
            '';
          };
        }
      )
    );
    default = { };
    description = ''
      Scopes defined as modules and used to generate Nixpkgs overlays.
    '';
  };

  config = {
    flake.overlays.default = _: config.scopes.default _;
  };
}
