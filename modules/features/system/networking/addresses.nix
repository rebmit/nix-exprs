{ lib, ... }:

{ host, ... }:

let
  cfg = host.networking;
in
{
  configs.host =
    { ... }:
    {
      options = {
        networking = {
          addresses = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            readOnly = true;
            default = cfg.ipv6.addresses ++ cfg.ipv4.addresses;
            description = ''
              Static IP addresses of this host.
            '';
          };
          ipv4.addresses = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
              Static IPv4 addresses of this host.
            '';
          };
          ipv6.addresses = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
              Static IPv6 addresses of this host.
            '';
          };
        };
      };
    };
}
