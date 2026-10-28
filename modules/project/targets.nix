{ lib, ... }:

{ config, ... }:

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

    perTarget = lib.mkOption {
      type = lib.types.deferredModule;
      default = { };
      apply =
        module: name: target:
        (lib.evalModules {
          modules = [ module ];
          prefix = [
            "perTarget"
            name
          ];
          specialArgs = { inherit target; };
          class = "perTarget";
        }).config;
      description = ''
        A module applied over each configured target.
      '';
    };

    allTargets = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      readOnly = true;
      default = lib.mapAttrs config.perTarget config.targets;
      description = ''
        Evaluated configurations for each of targets.
      '';
    };
  };
}
