{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  unify.profiles.networking._.hostname =
    { host, ... }:
    {
      requires = [ "profiles/networking/addresses" ];

      contexts.host =
        { config, ... }:
        {
          options = {
            hostName = mkOption {
              type = types.str;
              default = config.name;
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
              default = "${config.hostName}.${config.domain}";
              description = ''
                The fully qualified domain name (FQDN) of this host.
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
