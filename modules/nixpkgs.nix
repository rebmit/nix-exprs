# Portions of this file are sourced from
# https://github.com/linyinfeng/nur-packages/blob/73fea6901c19df2f480e734a75bc22dbabde3a53/flake-modules/nixpkgs.nix (MIT License)
# https://github.com/drupol/infra/blob/554c9279106bfbf6cc51646dccb5e5cae4f1affb/modules/flake-parts/unfree-packages.nix (MIT License)
{
  inputs,
  self,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.lists) foldl any elem;
  inherit (lib.strings) getName;
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

  nixpkgsPredicatesModule = _: {
    options.perSystem = mkPerSystemOption (
      { config, ... }:
      let
        predicateOption = mkOption {
          type = (types.functionTo types.bool) // {
            merge =
              _loc: defs:
              let
                funcs = map (d: d.value) defs;
              in
              foldl (acc: f: acc ++ [ f ]) [ ] funcs;
          };
          default = _: false;
        };

        cfg = config.nixpkgs.predicates;
      in
      {
        _file = ./nixpkgs.nix;

        options.nixpkgs.predicates = {
          allowUnfree = predicateOption // {
            description = ''
              List of predicates deciding which packages are allowed even if unfree.
              Only effective when `allowUnfree = false`.
            '';
          };
          allowNonSource = predicateOption // {
            description = ''
              List of predicates deciding which packages are allowed even if they are not built from source.
              Only effective when `allowNonSource = false`.
            '';
          };
          allowBroken = predicateOption // {
            description = ''
              List of predicates deciding which packages are allowed even if marked as broken.
              Only effective when `allowBroken = false`.
            '';
          };
          allowInsecure = predicateOption // {
            description = ''
              List of predicates deciding which packages are allowed even if marked as insecure.
            '';
          };
        };

        config = {
          nixpkgs.config = {
            allowUnfreePredicate = p: any (f: f p) cfg.allowUnfree;
            allowNonSourcePredicate = p: any (f: f p) cfg.allowNonSource;
            allowBrokenPredicate = p: any (f: f p) cfg.allowBroken;
            allowInsecurePredicate = p: any (f: f p) cfg.allowInsecure;
          };
        };
      }
    );
  };
in
{
  imports = [
    nixpkgsModule
    nixpkgsPredicatesModule
  ];

  flake.modules.flake = {
    nixpkgs = nixpkgsModule;
    nixpkgsPredicates = nixpkgsPredicatesModule;
  };

  perSystem = {
    nixpkgs = {
      config = {
        allowNonSource = false;
      };
      overlays = [
        self.overlays.default
      ];
      predicates = {
        allowNonSource =
          p:
          elem (getName p) [
            # keep-sorted start
            "cargo-bootstrap"
            "go"
            "rustc-bootstrap"
            "rustc-bootstrap-wrapper"
            # keep-sorted end
          ];
      };
    };
  };
}
