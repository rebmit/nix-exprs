{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrs optionalAttrs;
  inherit (lib.options) mkOption;

  overlaysModule =
    { options, config, ... }:
    {
      _file = ./overlays.nix;

      options.overlays = mkOption {
        type = types.lazyAttrsOf (types.functionTo (types.lazyAttrsOf (types.uniq types.raw)));
        default = { };
        apply = mapAttrs (
          _: f: final: prev:
          f { inherit final prev; }
        );
        description = ''
          Overlays defined as functions and composed through the module system.
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
