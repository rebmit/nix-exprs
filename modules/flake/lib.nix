{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.fixedPoints) fix;
  inherit (lib.options) mkOption;

  libModule =
    { config, ... }:
    {
      _file = ./lib.nix;

      options.lib = mkOption {
        type =
          let
            libType = types.lazyAttrsOf (
              types.oneOf [
                libType
                (types.uniq types.raw)
              ]
            );
          in
          types.functionTo libType;
        default = { };
        apply = fix;
        description = ''
          Library functions as functions and composed through the module system.
        '';
      };

      config = {
        flake = {
          lib = config.lib;
        };
      };
    };
in
{
  flake.flakeModules.lib = libModule;
}
