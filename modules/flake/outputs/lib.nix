{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;

  libModule =
    { ... }:
    {
      _file = ./lib.nix;

      options.flake.lib = mkOption {
        type = types.submodule (
          { config, ... }:
          {
            freeformType =
              let
                libType = types.lazyAttrsOf (
                  types.oneOf [
                    libType
                    types.raw
                  ]
                );
              in
              libType;

            _module.args.self = config;
          }
        );
        default = { };
        description = ''
          A set of library functions provided by the flake.
        '';
      };
    };
in
{
  flake.flakeModules.lib = libModule;
}
