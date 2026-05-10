{
  inputs,
  lib,
  pkgs,
  ...
}:

{ modules, dev, ... }:

let
  cfg = dev.config.pre-commit;
in
{
  configs.dev =
    { ... }:
    {
      options = {
        pre-commit = {
          path = lib.mkOption {
            type = lib.types.pathInStore;
            default = inputs.git-hooks-nix;
            description = ''
              Path to the git-hooks.nix source tree to be imported.
            '';
          };
          config = lib.mkOption {
            type = lib.types.raw;
            readOnly = true;
            default =
              (lib.evalModules {
                modules = [
                  (cfg.path + "/modules/all-modules.nix")
                  modules.pre-commit
                ];
                specialArgs = { inherit pkgs; };
              }).config;
            description = ''
              Evaluated pre-commit configuration.
            '';
          };
        };
      };
    };

  modules.devshell =
    { ... }:
    {
      devshell.startup.pre-commit-hook.text = cfg.config.shellHook;
    };

  modules.pre-commit =
    { ... }:
    {
      package = pkgs.prek;
    };
}
