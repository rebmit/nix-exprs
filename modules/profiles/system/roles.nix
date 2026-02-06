{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  unify.profiles.system._.roles =
    { ... }:
    {
      contexts.host = {
        options = {
          roles = mkOption {
            type = types.listOf (
              types.enum [
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
    };
}
