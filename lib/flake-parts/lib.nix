{ config, lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  options.lib = mkOption {
    type = types.submodule (
      { config, ... }:
      {
        freeformType = types.lazyAttrsOf types.raw;
        _module.args.self = config;
      }
    );
    default = { };
    description = ''
      An extensible set of library functions.
    '';
  };

  config = {
    flake.lib = config.lib;
  };
}
