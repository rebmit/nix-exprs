{ lib, ... }:

{ config, project, ... }:

{
  configs.project =
    { ... }:
    let
      targetType = lib.types.submodule (
        { ... }:
        {
          options = {
            localSystem = lib.mkOption {
              type = lib.types.attrs;
              description = ''
                The system packages will be built on.
              '';
            };
            crossSystem = lib.mkOption {
              type = lib.types.nullOr lib.types.attrs;
              default = null;
              description = ''
                The system packages will ultimately be run on.
              '';
            };
          };
        }
      );
    in
    {
      options = {
        targets = lib.mkOption {
          type = lib.types.lazyAttrsOf (
            lib.types.coercedTo lib.types.str (config: { localSystem = { inherit config; }; }) targetType
          );
          default = { };
          description = ''
            Named targets defining where packages are built and run.
          '';
        };

        allTargets = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.raw;
          readOnly = true;
          default = lib.mapAttrs (
            _: target:
            (lib.evalModules {
              modules = [ config.modules.perTarget ];
              specialArgs = { inherit target; };
            }).config
          ) project.targets;
          description = ''
            The target-specific config for each of targets.
          '';
        };
      };
    };

  modules.perTarget = { };
}
