{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.lists) foldl any;
  inherit (lib.options) mkOption;
  inherit (flake-parts-lib) mkPerSystemOption;

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
        _file = ./predicates.nix;

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
  imports = [ nixpkgsPredicatesModule ];

  flake.modules.flake.nixpkgsPredicates = nixpkgsPredicatesModule;
}
