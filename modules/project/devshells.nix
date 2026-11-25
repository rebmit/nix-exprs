{ inputs, lib, ... }:

{ config, ... }:

{
  perTarget =
    { pkgs, ... }:
    {
      options.devshells = lib.mkOption {
        type = lib.types.lazyAttrsOf (
          lib.rebmit.submoduleWith {
            class = "dev";
            args = {
              inherit inputs lib pkgs;
            };
          }
        );
        default = { };
        description = ''
          Devshells evaluated with the dev modules per target.
        '';
      };
    };

  outputs = {
    devshells = lib.mapAttrs (
      _: target: lib.mapAttrs (_: shell: shell.outputs.shell) target.devshells
    ) config.allTargets;

    formatters = lib.mapAttrs (
      _: target: lib.mapAttrs (_: shell: shell.outputs.formatter) target.devshells
    ) config.allTargets;
  };
}
