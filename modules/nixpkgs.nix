# Portions of this file are sourced from
# https://github.com/linyinfeng/nur-packages/blob/73fea6901c19df2f480e734a75bc22dbabde3a53/flake-modules/nixpkgs.nix (MIT License)
{
  inputs,
  self,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
  inherit (flake-parts-lib) mkPerSystemOption;

  nixpkgsModule = _: {
    options.perSystem = mkPerSystemOption (
      {
        config,
        system,
        ...
      }:
      let
        cfg = config.nixpkgs;
      in
      {
        _file = ./nixpkgs.nix;

        # https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/default.nix
        options.nixpkgs = {
          path = mkOption {
            type = types.path;
            default = inputs.nixpkgs;
            description = ''
              Path to the nixpkgs source tree to be imported.
            '';
          };
          localSystem = mkOption {
            type = types.attrs;
            default = { inherit system; };
            description = ''
              The system packages will be built on.
            '';
          };
          crossSystem = mkOption {
            type = types.nullOr types.attrs;
            default = null;
            description = ''
              The system packages will ultimately be run on.
            '';
          };
          config = mkOption {
            type = types.attrsOf types.raw;
            default = { };
            description = ''
              Configuration attribute set passed to nixpkgs.
            '';
          };
          overlays = mkOption {
            type = types.listOf types.raw;
            default = [ ];
            description = ''
              List of overlays layers used to extend Nixpkgs.
            '';
          };
          crossOverlays = mkOption {
            type = types.listOf types.raw;
            default = [ ];
            description = ''
              List of overlays to apply to target packages only.
            '';
          };
        };

        config = {
          _module.args.pkgs = import cfg.path {
            inherit (cfg)
              localSystem
              crossSystem
              config
              overlays
              crossOverlays
              ;
          };
        };
      }
    );
  };
in
{
  imports = [ nixpkgsModule ];

  flake.modules.flake.nixpkgs = nixpkgsModule;

  perSystem = {
    nixpkgs = {
      overlays = [ self.overlays.default ];
    };
  };
}
