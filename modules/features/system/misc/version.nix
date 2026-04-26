{ lib, __findFile, ... }:

{ host, ... }:

{
  includes = [ <rebmit/features/system/misc/class> ];

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
    { config, ... }:
    let
      cfg = config.system;
      darwin = host.system.darwin;
    in
    {
      system = {
        darwinRevision = darwin.path.revision or darwin.path.rev or null;
        darwinVersionSuffix =
          if cfg.darwinRevision != null then ".${lib.substring 0 12 cfg.darwinRevision}" else "pre-git";

        stateVersion = darwin.stateVersion;
      };
    };

  modules.nixos =
    { config, ... }:
    let
      cfg = config.system;
      nixos = host.system.nixos;
    in
    {
      system = {
        nixos = {
          revision = nixos.path.revision or nixos.path.rev or null;
          versionSuffix =
            if cfg.nixos.revision != null then ".${lib.substring 0 12 cfg.nixos.revision}" else "pre-git";
        };

        stateVersion = nixos.stateVersion;
      };
    };
}
