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
        hosts = lib.mkOption {
          type = lib.types.lazyAttrsOf (
            lib.rebmit.types.latticeSubmoduleWith {
              includes = [
                <rebmit/features/system/misc/class>
              ];
              internalConfigs = [ "host" ];
              externalConfigs = { inherit project; };
              inputs = lib.removeAttrs args [
                "__findFile"
                "registry"
              ];
              registry = registry;
            }
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
