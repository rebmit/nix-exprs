{ self, lib, ... }:

let
  latticeSubmoduleWith =
    {
      includes ? [ ],
      excludes ? [ ],
      internalConfigs ? [ ],
      externalConfigs ? { },
      inputs ? { },
      registry ? { },
    }:
    lib.types.submodule (
      { config, ... }:
      {
        options = {
          config = lib.mkOption {
            type = lib.types.raw;
            readOnly = true;
            default = self.modules.lattice {
              inherit (config)
                includes
                excludes
                internalConfigs
                externalConfigs
                inputs
                registry
                ;
            };
            description = ''
              Evaluated lattice configuration.
            '';
          };
          includes = lib.mkOption {
            type = lib.types.listOf lib.types.raw;
            description = ''
              Providers to include.
            '';
          };
          excludes = lib.mkOption {
            type = lib.types.listOf lib.types.raw;
            description = ''
              Providers to exclude.
            '';
          };
          internalConfigs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = ''
              Names of configs that are allowed to be defined internally.
            '';
          };
          externalConfigs = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            description = ''
              Fully evaluated config instances provided externally.
            '';
          };
          inputs = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            description = ''
              Inputs passed to providers.
            '';
          };
          registry = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            description = ''
              Registry mapping names to paths.
            '';
          };
        };

        config = {
          inherit
            includes
            excludes
            internalConfigs
            externalConfigs
            inputs
            registry
            ;
        };
      }
    );
in
{
  inherit
    latticeSubmoduleWith
    ;
}
