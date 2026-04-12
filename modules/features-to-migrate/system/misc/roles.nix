{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  unify.features.system._.misc._.roles =
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
