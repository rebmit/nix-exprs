# Portions of this file are sourced from
# https://github.com/NickCao/flakes/blob/3b03efb676ea602575c916b2b8bc9d9cd13b0d85/modules/gravity/default.nix (MIT License)
{ self, lib, ... }:
let
  inherit (lib) types;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (self.lib.network.ipv6) cidrHost;
in
{
  flake.nixosModules.enthalpy =
    { config, ... }:
    let
      cfg = config.services.enthalpy;
    in
    {
      options.services.enthalpy = {
        enable = mkEnableOption "enthalpy overlay network, next generation";
        network = mkOption {
          type = types.str;
          description = ''
            Prefix of the enthalpy network.
          '';
        };
        prefix = mkOption {
          type = types.str;
          description = ''
            Prefix to be announced for this node in the enthalpy network.
          '';
        };
      };

      config = mkIf cfg.enable {
        netns.enthalpy = {
          sysctl = {
            "net.ipv6.conf.all.forwarding" = 1;
            "net.ipv6.conf.default.forwarding" = 1;
            "net.netfilter.nf_hooks_lwtunnel" = 1;
          };

          services.resolved = {
            enable = true;
            dns = [
              "2620:fe::fe#dns.quad9.net"
              "2620:fe::9#dns.quad9.net"
              "2606:4700:4700::1111#cloudflare-dns.com"
              "2606:4700:4700::1001#cloudflare-dns.com"
            ];
          };

          services.networkd = {
            enable = true;
            config = {
              networkConfig = {
                ManageForeignRoutes = false;
              };
            };
            netdevs = {
              "20-enthalpy" = {
                netdevConfig = {
                  Kind = "dummy";
                  Name = "enthalpy";
                };
              };
            };
            networks = {
              "20-enthalpy" = {
                matchConfig.Name = "enthalpy";
                networkConfig = {
                  Address = [ "${cidrHost 1 cfg.prefix}/128" ];
                };
              };
            };
          };
        };
      };
    };
}
