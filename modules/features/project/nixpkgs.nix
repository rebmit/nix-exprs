{ inputs, lib, ... }:

{
  includes = [ ./targets.nix ];

  configs.project =
    { forEachTarget, ... }:
    {
      options = {
        outputs = {
          packages = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            readOnly = true;
            default = forEachTarget (lib.getAttr "pkgs");
            description = ''
              Nixpkgs package sets per target.
            '';
          };
        };
      };
    };

  modules.perTarget =
    {
      target,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.nixpkgs;
    in
    {
      options = {
        nixpkgs = {
          path = lib.mkOption {
            type = lib.types.path;
            default = inputs.nixpkgs;
            description = ''
              Nixpkgs source tree path for pkgs.
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
        };

        pkgs = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.raw;
          readOnly = true;
          default = pkgs;
          description = ''
            Nixpkgs package sets per target.
          '';
        };
      };

      config = {
        _module.args.pkgs = import ../../../pkgs/top-level {
          inherit (target)
            localSystem
            crossSystem
            ;
          inherit (cfg)
            path
            config
            overlays
            crossOverlays
            ;
        };
      };
    };
}
