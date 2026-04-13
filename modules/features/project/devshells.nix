{
  lib,
  registry,
  __findFile,
  ...
}@args:

{ project, ... }:

{
  configs.project =
    { ... }:
    {
      options = {
        outputs = {
          devshells = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            readOnly = true;
            default = lib.mapAttrs (
              name: _:
              lib.mapAttrs (
                _: devshell: devshell.config.configs.dev.devshell.shell
              ) project.allTargets.${name}.devshells
            ) project.targets;
            description = ''
              Development shells per target.
            '';
          };

          formatters = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = lib.mapAttrs (
              name: _:
              lib.mapAttrs (
                _: devshell: devshell.config.configs.dev.treefmt.config.build.wrapper
              ) project.allTargets.${name}.devshells
            ) project.targets;
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
            lib.rebmit.types.latticeSubmoduleWith {
              includes = [
                <rebmit/features/devshell/devshell>
                <rebmit/features/devshell/pre-commit>
                <rebmit/features/devshell/treefmt>
              ];
              internalConfigs = [ "dev" ];
              externalConfigs = { inherit project; };
              inputs =
                lib.removeAttrs args [
                  "__findFile"
                  "registry"
                ]
                // {
                  inherit pkgs;
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
