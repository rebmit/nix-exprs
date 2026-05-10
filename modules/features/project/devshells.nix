{
  inputs,
  lib,
  registry,
  __findFile,
  ...
}:

{ project, ... }:

{
  includes = [ ./targets.nix ];

  configs.project =
    { forEachTarget, ... }:
    {
      options = {
        outputs = {
          devshells = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            readOnly = true;
            default = forEachTarget (
              target:
              lib.mapAttrs (_: devshell: devshell.config.configs.dev.config.devshell.shell) target.devshells
            );
            description = ''
              Development shells per target.
            '';
          };

          formatters = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = forEachTarget (
              target:
              lib.mapAttrs (
                _: devshell: devshell.config.configs.dev.config.treefmt.config.build.wrapper
              ) target.devshells
            );
            description = ''
              Formatters per target.
            '';
          };
        };
      };
    };

  modules.perTarget =
    { pkgs, ... }:
    {
      options = {
        devshells = lib.mkOption {
          type = lib.types.lazyAttrsOf (
            lib.rebmit.types.latticeSubmodule {
              includes = [
                <rebmit/features/devshell/devshell>
                <rebmit/features/devshell/pre-commit>
                <rebmit/features/devshell/treefmt>
              ];
              internalConfigs = [ "dev" ];
              externalConfigs = { inherit project; };
              inputs = {
                inherit inputs lib pkgs;
              };
              registry = registry;
            }
          );
          default = { };
          description = ''
            Development shells per target.
          '';
        };
      };
    };
}
