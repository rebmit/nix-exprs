{
  inputs,
  lib,
  registry,
  __findFile,
  ...
}:

{ project, ... }:

{
  configs.project =
    { ... }:
    {
      options = {
        hosts = lib.mkOption {
          type = lib.types.lazyAttrsOf (
            lib.rebmit.types.latticeSubmodule (
              { name, ... }:
              {
                includes = [ <rebmit/profiles/system/minimal> ];
                excludes = [ ];
                internalConfigs = [ "host" ];
                externalConfigs = { inherit project; };
                inputs = { inherit name inputs lib; };
                registry = registry;
              }
            )
          );
          default = { };
          description = ''
            Host configurations.
          '';
        };

        outputs = {
          hosts = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            readOnly = true;
            default = lib.mapAttrs (_: host: host.config.configs.host.system.config) project.hosts;
            description = ''
              Host configurations.
            '';
          };
        };
      };
    };
}
