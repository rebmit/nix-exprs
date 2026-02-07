{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;

  darwinConfigurationsModule =
    { ... }:
    {
      _file = ./darwin-configurations.nix;

      options.flake.darwinConfigurations = mkOption {
        type = types.lazyAttrsOf types.raw;
        default = { };
        description = ''
          Instantiated nix-darwin configurations.
        '';
      };
    };
in
{
  imports = [ darwinConfigurationsModule ];

  flake.flakeModules.darwinConfigurations = darwinConfigurationsModule;
}
