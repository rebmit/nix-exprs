{ lib, data, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  unify.features.system._.networking._.hostname =
    { host, ... }:
    {
      contexts.host = {
        options = {
          hostName = mkOption {
            type = types.str;
            description = ''
              The hostname of this host.
            '';
          };
          domain = mkOption {
            type = types.str;
            default = "rebmit.link";
            description = ''
              The dns domain name of this host.
            '';
          };
          fqdn = mkOption {
            type = types.str;
            default = "${host.hostName}.${host.domain}";
            description = ''
              The fully qualified domain name (FQDN) of this host.
            '';
          };
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
            default = data.hosts.${host.hostName}.endpoints_v4 or [ ];
            description = ''
              IPv4 addresses of this host.
            '';
          };
          ipv6.addresses = mkOption {
            type = types.listOf types.str;
            default = data.hosts.${host.hostName}.endpoints_v6 or [ ];
            description = ''
              IPv6 addresses of this host.
            '';
          };
        };
      };

      dns =
        { ... }:
        {
          ${host.domain}.subdomains.${host.hostName} = {
            A = host.ipv4.addresses;
            AAAA = host.ipv6.addresses;
          };
        };

      nixos =
        { ... }:
        {
          networking = {
            domain = host.domain;
            fqdn = host.fqdn;
            hostName = host.hostName;
          };
        };

      darwin =
        { ... }:
        {
          networking = {
            computerName = host.hostName;
            domain = host.domain;
            fqdn = host.fqdn;
            hostName = host.hostName;
            localHostName = host.hostName;
          };
        };
    };
}
