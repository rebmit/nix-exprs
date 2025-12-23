{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.lists) any;
  inherit (lib.options) mkOption;
  inherit (flake-parts-lib) mkPerSystemOption;

  mkPredicateOption =
    args:
    mkOption (
      {
        type = (types.functionTo types.bool) // {
          merge =
            _loc: defs:
            let
              funcs = map (d: d.value) defs;
            in
            p: any (f: f p) funcs;
        };
        default = _: false;
      }
      // args
    );

  # https://github.com/linyinfeng/nur-packages/blob/73fea6901c19df2f480e734a75bc22dbabde3a53/flake-modules/nixpkgs.nix
  nixpkgsModule =
    { inputs, ... }:
    {
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
              type = types.listOf (types.functionTo (types.functionTo (types.lazyAttrsOf types.unspecified)));
              default = [ ];
              description = ''
                List of overlays layers used to extend Nixpkgs.
              '';
            };
            crossOverlays = mkOption {
              type = types.listOf (types.functionTo (types.functionTo (types.lazyAttrsOf types.unspecified)));
              default = [ ];
              description = ''
                List of overlays to apply to target packages only.
              '';
            };
            predicates = {
              allowUnfree = mkPredicateOption {
                description = ''
                  List of predicates deciding which packages are allowed even if unfree.
                  Only effective when `allowUnfree = false`.
                '';
              };
              allowNonSource = mkPredicateOption {
                description = ''
                  List of predicates deciding which packages are allowed even if they are not built from source.
                  Only effective when `allowNonSource = false`.
                '';
              };
              allowBroken = mkPredicateOption {
                description = ''
                  List of predicates deciding which packages are allowed even if marked as broken.
                  Only effective when `allowBroken = false`.
                '';
              };
              allowInsecure = mkPredicateOption {
                description = ''
                  List of predicates deciding which packages are allowed even if marked as insecure.
                '';
              };
            };
          };

          config = {
            _module.args.pkgs = import cfg.path {
              inherit (cfg)
                localSystem
                crossSystem
                overlays
                crossOverlays
                ;

              config = cfg.config // {
                allowUnfreePredicate = cfg.predicates.allowUnfree;
                allowNonSourcePredicate = cfg.predicates.allowNonSource;
                allowBrokenPredicate = cfg.predicates.allowBroken;
                allowInsecurePredicate = cfg.predicates.allowInsecure;
              };
            };
          };
        }
      );
    };
in
{
  flake.flakeModules.nixpkgs = nixpkgsModule;
}
