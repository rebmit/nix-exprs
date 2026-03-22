{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.options) mkOption;

  overlaysModule =
    { config, ... }:
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
        flake = {
          overlays.default = config.overlays.default;
        };
      };
    };
in
{
  flake.flakeModules.overlays = overlaysModule;
}
