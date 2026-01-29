{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.options) mkOption;

  overlaysModule =
    { options, config, ... }:
    {
      _file = ./overlays.nix;

      options.overlays = mkOption {
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
                  Functor used to evaluate the overlay module as a Nixpkgs overlay.
                '';
              };

              config._module.args = {
                final = throw ''
                  `final` is only defined when applying the module as a Nixpkgs overlay.
                '';
                prev = throw ''
                  `prev` is only defined when applying the module as a Nixpkgs overlay.
                '';
              };
            }
          )
        );
        default = { };
        description = ''
          Overlays defined as modules and used to generate Nixpkgs overlays.
        '';
      };

      config = {
        flake =
          optionalAttrs (options.flake.type.getSubOptions [ ] ? overlays && config.overlays ? default)
            {
              overlays.default = config.overlays.default;
            };
      };
    };
in
{
  flake.flakeModules.overlays = overlaysModule;
}
