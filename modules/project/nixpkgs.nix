{ inputs, lib, ... }:

{ config, ... }:

{
  outputs.packages = lib.mapAttrs (_: target: target.nixpkgs.pkgs) config.allTargets;

  perTarget =
    {
      target,
      config,
      options,
      ...
    }:
    let
      cfg = config.nixpkgs;
    in
    {
      options.nixpkgs = {
        source = lib.mkOption {
          type = lib.types.pathInStore;
          default =
            inputs.nixpkgs or (throw ''
              `${options.nixpkgs.source}` is used but is not set.

              Consider providing `inputs.nixpkgs` or explicitly setting `${options.nixpkgs.source}`.
            '');
          description = ''
            Nixpkgs source tree for pkgs.
          '';
        };

        config = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.raw;
          default = { };
          description = ''
            Configuration attribute set passed to Nixpkgs.
          '';
        };

        overlays = lib.mkOption {
          type = lib.types.listOf lib.types.raw;
          default = [ ];
          description = ''
            List of overlays layers used to extend Nixpkgs.
          '';
        };

        crossOverlays = lib.mkOption {
          type = lib.types.listOf lib.types.raw;
          default = [ ];
          description = ''
            List of overlays to apply to target packages only.
          '';
        };

        pkgs = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.raw;
          readOnly = true;
          default = import ../../pkgs/top-level {
            inherit (target)
              localSystem
              crossSystem
              ;
            inherit (cfg)
              source
              config
              overlays
              crossOverlays
              ;
          };
          description = ''
            Nixpkgs package sets per target.
          '';
        };
      };

      config = {
        _module.args = {
          inherit (config) pkgs;
        };
      };
    };
}
