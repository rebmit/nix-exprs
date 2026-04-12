{ inputs, lib, ... }:

{ project, ... }:

{
  includes = [ ./targets.nix ];

  configs.project =
    { ... }:
    {
      options = {
        outputs = {
          packages = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            readOnly = true;
            default = lib.mapAttrs (name: _: project.allTargets.${name}.pkgs) project.targets;
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
              Path to the nixpkgs source tree to be imported.
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
