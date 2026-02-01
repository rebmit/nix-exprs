{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  unify.profiles.networking._.addresses =
    { host, ... }:
    {
      contexts.host =
        { ... }:
        {
          options = {
            addresses = mkOption {
              type = types.listOf types.str;
              readOnly = true;
              default = host.ipv6.addresses ++ host.ipv4.addresses;
              description = ''
                IP addresses of this host.
              '';
            };
            ipv4.addresses = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = ''
                IPv4 addresses of this host.
              '';
            };
            ipv6.addresses = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = ''
                IPv6 addresses of this host.
              '';
            };
          };
        };
    };
}
