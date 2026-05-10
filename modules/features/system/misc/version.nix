{ lib, ... }:

{ host, ... }:

let
  cfg = host.config.system;
in
{
  configs.host =
    { ... }:
    {
      options = {
        system = {
          darwin = {
            stateVersion = lib.mkOption {
              type = lib.types.int;
              description = ''
                System state version for compatibility.
              '';
            };
          };

          nixos = {
            stateVersion = lib.mkOption {
              type = lib.types.str;
              description = ''
                System state version for compatibility.
              '';
            };
          };
        };
      };
    };

  modules.darwin =
    { ... }:
    {
      system = {
        configurationRevision = lib.rebmit.trivial.revision;
        stateVersion = cfg.darwin.stateVersion;
      };
    };

  modules.nixos =
    { ... }:
    {
      system = {
        configurationRevision = lib.rebmit.trivial.revision;
        stateVersion = cfg.nixos.stateVersion;
      };
    };
}
