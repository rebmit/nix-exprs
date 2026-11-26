{ inputs, lib, ... }:

{ config, options, ... }:

let
  cfg = config.system;
in
{
  options.system = {
    class = lib.mkOption {
      type = lib.types.enum [
        "darwin"
        "nixos"
      ];
      description = ''
        Module system class of the system.
      '';
    };

    config = lib.mkOption {
      type = lib.types.raw;
      readOnly = true;
      default =
        {
          "darwin" = cfg.darwin.config.config;
          "nixos" = cfg.nixos.config.config;
        }
        .${cfg.class};
      description = ''
        Configuration of the module system selected by class.
      '';
    };

    darwin = {
      source = lib.mkOption {
        type = lib.types.pathInStore;
        default =
          inputs.nix-darwin or (throw ''
            `${options.system.darwin.source}` is used but is not set.

            Consider providing `inputs.nix-darwin` or explicitly setting `${options.system.darwin.source}`.
          '');
        description = ''
          nix-darwin source tree for evaluation.
        '';
      };

      config = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        default = cfg.darwin.source.lib.darwinSystem {
          modules = [ (config._.darwin or { }) ];
        };
        description = ''
          nix-darwin configuration.
        '';
      };
    };

    nixos = {
      source = lib.mkOption {
        type = lib.types.pathInStore;
        default =
          inputs.nixpkgs or (throw ''
            `${options.system.nixos.source}` is used but is not set.

            Consider providing `inputs.nixpkgs` or explicitly setting `${options.system.nixos.source}`.
          '');
        description = ''
          Nixpkgs source tree for NixOS evaluation.
        '';
      };

      config = lib.mkOption {
        type = lib.types.raw;
        readOnly = true;
        default = cfg.nixos.source.lib.nixosSystem {
          modules = [ (config._.nixos or { }) ];
        };
        description = ''
          NixOS configuration.
        '';
      };
    };
  };

  config = {
    _module.args = {
      osConfig = cfg.config;
      nixosConfig = if cfg.class == "nixos" then cfg.config else null;
      darwinConfig = if cfg.class == "darwin" then cfg.config else null;
    };
  };
}
