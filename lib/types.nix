{ self, lib, ... }:

let
  latticeSubmodule =
    module:
    lib.types.submodule (
      { config, ... }:
      {
        imports = [ module ];

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
            default = [ ];
            description = ''
              Providers to include.
            '';
          };
          excludes = lib.mkOption {
            type = lib.types.listOf lib.types.raw;
            default = [ ];
            description = ''
              Providers to exclude.
            '';
          };
          internalConfigs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
              Names of configs that are allowed to be defined internally.
            '';
          };
          externalConfigs = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = { };
            description = ''
              Fully evaluated config instances provided externally.
            '';
          };
          inputs = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = { };
            description = ''
              Inputs passed to providers.
            '';
          };
          registry = lib.mkOption {
            type = lib.types.lazyAttrsOf lib.types.raw;
            default = { };
            description = ''
              Registry mapping names to paths.
            '';
          };
        };
      }
    );
in
{
  inherit
    latticeSubmodule
    ;
}
