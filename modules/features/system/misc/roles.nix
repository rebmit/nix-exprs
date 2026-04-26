{ lib, ... }:

{
  configs.host =
    { ... }:
    {
      options = {
        roles = lib.mkOption {
          type = lib.types.listOf (
            lib.types.enum [
              "server"
              "workstation"
            ]
          );
          default = [ ];
          description = ''
            The roles assigned to this host.
          '';
        };
      };
    };
}
