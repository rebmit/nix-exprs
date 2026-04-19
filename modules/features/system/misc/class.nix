{ inputs, lib, ... }:

{ modules, host, ... }:

let
  cfg = host.system;
in
{
  configs.host =
    { ... }:
    {
      options = {
        system = {
          class = lib.mkOption {
            type = lib.types.enum [
              "nixos"
              "darwin"
            ];
            description = ''
              Module system class of the system.
            '';
          };

          config = lib.mkOption {
            type = lib.types.raw;
            readOnly = true;
            default = cfg.${cfg.class}.config;
            description = ''
              Evaluated system configuration.
            '';
          };

          darwin = {
            path = lib.mkOption {
              type = lib.types.raw;
              default = inputs.nix-darwin;
              description = ''
                Path to the nix-darwin source tree to be imported.
              '';
            };
            config = lib.mkOption {
              type = lib.types.raw;
              readOnly = true;
              default = import (cfg.darwin.path + "/eval-config.nix") {
                inherit lib;
                modules = [ modules.darwin ];
              };
              description = ''
                Evaluated nix-darwin configuration.
              '';
            };
          };

          nixos = {
            path = lib.mkOption {
              type = lib.types.raw;
              default = inputs.nixpkgs;
              description = ''
                Path to the nixpkgs source tree to be imported.
              '';
            };
            config = lib.mkOption {
              type = lib.types.raw;
              readOnly = true;
              default = import (cfg.nixos.path + "/nixos/lib/eval-config.nix") {
                system = null;
                inherit lib;
                modules = [ modules.nixos ];
              };
              description = ''
                Evaluated nixos configuration.
              '';
            };
          };
        };
      };
    };
}
