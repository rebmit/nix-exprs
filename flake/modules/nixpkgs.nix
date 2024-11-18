# Portions of this file are sourced from
# https://github.com/linyinfeng/nur-packages/blob/73fea6901c19df2f480e734a75bc22dbabde3a53/flake-modules/nixpkgs.nix
{
  inputs,
  flake-parts-lib,
  ...
}:
let
  inherit (flake-parts-lib) mkPerSystemOption;
in
{
  options.perSystem = mkPerSystemOption (
    {
      config,
      system,
      lib,
      ...
    }:
    let
      cfg = config.nixpkgs;
    in
    with lib;
    {
      _file = ./nixpkgs.nix;
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/default.nix
      options.nixpkgs = {
        path = mkOption {
          type = types.path;
          default = inputs.nixpkgs;
          defaultText = "inputs.nixpkgs";
          description = ''
            Path to nixpkgs to be imported.
          '';
        };
        localSystem = mkOption {
          type = types.attrs;
          default = {
            inherit system;
          };
          description = ''
            The system packages will be built on.
          '';
        };
        crossSystem = mkOption {
          type = with types; nullOr attrs;
          default = null;
          description = ''
            The system packages will ultimately be run on.
          '';
        };
        config = mkOption {
          type = with types; attrsOf raw;
          default = { };
          description = ''
            Allow a configuration attribute set to be passed in as an argument.
          '';
        };
        overlays = mkOption {
          type = with types; listOf raw;
          default = [ ];
          description = ''
            List of overlays layers used to extend Nixpkgs.
          '';
        };
        crossOverlays = mkOption {
          type = with types; listOf raw;
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
}
