{
  inputs,
  lib,
  pkgs,
  ...
}:

{ modules, dev, ... }:

let
  devshell = import dev.devshell.path {
    system = throw "system not allowed to be used";
    inputs = throw "inputs not allowed to be used";
    nixpkgs = pkgs;
  };
in
{
  configs.dev =
    { ... }:
    {
      options = {
        devshell = {
          path = lib.mkOption {
            type = lib.types.path;
            default = inputs.devshell;
            description = ''
              Path to the devshell source tree to be imported.
            '';
          };
          config = lib.mkOption {
            type = lib.types.raw;
            readOnly = true;
            default =
              (devshell.eval {
                configuration = modules.devshell;
                inherit lib;
              }).config;
            description = ''
              Evaluated devshell configuration.
            '';
          };
          shell = lib.mkOption {
            type = lib.types.package;
            readOnly = true;
            default = dev.devshell.config.devshell.shell;
            description = ''
              Evaluated devshell derivation.
            '';
          };
        };
      };
    };

  modules.devshell = { };
}
