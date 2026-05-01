{
  name,
  lib,
  __findFile,
  ...
}:

{ host, ... }:

let
  cfg = host.networking;
in
{
  includes = [ <rebmit/features/system/networking/addresses> ];

  configs.host =
    { ... }:
    {
      options = {
        networking = {
          hostName = lib.mkOption {
            type = lib.types.str;
            default = name;
            description = ''
              The hostname of this host.
            '';
          };

          domain = lib.mkOption {
            type = lib.types.str;
            description = ''
              The dns domain name of this host.
            '';
          };

          fqdn = lib.mkOption {
            type = lib.types.str;
            default = "${cfg.hostName}.${cfg.domain}";
            description = ''
              The fully qualified domain name (FQDN) of this host.
            '';
          };
        };
      };

      config = {
        __key__ = lib.mkDefault cfg.hostName;
      };
    };

  modules.darwin =
    { ... }:
    {
      networking = {
        computerName = cfg.hostName;
        domain = cfg.domain;
        fqdn = cfg.fqdn;
        hostName = cfg.hostName;
        localHostName = cfg.hostName;
      };
    };

  modules.dns =
    { ... }:
    {
      ${cfg.domain}.subdomains.${cfg.hostName} = {
        A = cfg.ipv4.addresses;
        AAAA = cfg.ipv6.addresses;
      };
    };

  modules.nixos =
    { ... }:
    {
      networking = {
        domain = cfg.domain;
        fqdn = cfg.fqdn;
        hostName = cfg.hostName;
      };
    };
}
