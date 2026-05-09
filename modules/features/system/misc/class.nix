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
                "darwin" = cfg.darwin.config;
                "nixos" = cfg.nixos.config;
              }
              .${cfg.class};
            description = ''
              Evaluated system configuration.
            '';
          };

          darwin = {
            path = lib.mkOption {
              type = lib.types.path;
              default = inputs.nix-darwin;
              description = ''
                nix-darwin source tree path for evaluation.
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
              type = lib.types.path;
              default = inputs.nixpkgs;
              description = ''
                Nixpkgs source tree path for NixOS evaluation.
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
                Evaluated NixOS configuration.
              '';
            };
          };
        };
      };

      config = {
        _module.args.pkgs = lib.mkDefault (throw ''
          `pkgs` was used but is not set.

          Consider including the Nixpkgs module or explicitly providing `pkgs`.
        '');
      };
    };

  modules.darwin =
    { config, ... }:
    {
      system = {
        darwinRevision = lib.rebmit.trivial.revisionFromPath cfg.darwin.path;
        darwinVersionSuffix = lib.rebmit.trivial.versionSuffixFromRevision config.system.darwinRevision;
      };
    };

  modules.nixos =
    { config, ... }:
    {
      system = {
        nixos = {
          revision = lib.rebmit.trivial.revisionFromPath cfg.nixos.path;
          versionSuffix = lib.rebmit.trivial.versionSuffixFromRevision config.system.nixos.revision;
        };
      };
    };
}
