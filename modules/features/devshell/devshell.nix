{
  inputs,
  lib,
  pkgs,
  ...
}:

{ modules, dev, ... }:

let
  cfg = dev.config.devshell;
in
{
  configs.dev =
    { ... }:
    {
      options = {
        devshell = {
          path = lib.mkOption {
            type = lib.types.pathInStore;
            default = inputs.devshell;
            description = ''
              Path to the devshell source tree to be imported.
            '';
          };
          config = lib.mkOption {
            type = lib.types.raw;
            readOnly = true;
            default =
              (
                (import cfg.path {
                  system = throw "system not allowed to be used";
                  inputs = throw "inputs not allowed to be used";
                  nixpkgs = pkgs;
                }).eval
                {
                  configuration = modules.devshell;
                  inherit lib;
                }
              ).config;
            description = ''
              Evaluated devshell configuration.
            '';
          };
          shell = lib.mkOption {
            type = lib.types.package;
            readOnly = true;
            default = cfg.config.devshell.shell;
            description = ''
              Evaluated devshell derivation.
            '';
          };
        };
      };
    };

  modules.devshell = { };
}
