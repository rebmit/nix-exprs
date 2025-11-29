{ lib, ... }:
let
  inherit (lib.modules) mkMerge mkForce;
in
{
  flake.unify.configs.nixos.flandre-t1 = {
    meta = {
      includes = [ "services/enthalpy/common" ];
    };

    module =
      { config, ... }:
      {
        systemd.network = {
          enable = true;
          wait-online.anyInterface = true;
          networks = {
            "20-enp3s0" = {
              matchConfig.Name = "enp3s0";
              networkConfig = {
                DHCP = "ipv4";
                IPv6AcceptRA = true;
                IPv6PrivacyExtensions = true;
              };
              dhcpV4Config.RouteMetric = 1024;
              ipv6AcceptRAConfig.RouteMetric = 1024;
            };
          };
        };

        services.enthalpy = {
          ipsec = {
            interfaces = [ "enp3s0" ];
          };
          clat = {
            enable = true;
            segment = [ "2a0e:aa07:e21c:5866::3" ];
          };
          srv6.enable = true;
        };

        netns.enthalpy.nftables.tables = {
          filter6 = {
            family = "ip6";
            content = ''
              chain input {
                type filter hook input priority filter; policy accept;
                iifname "enta*" ct state established,related counter accept
                iifname "enta*" ip6 saddr { fe80::/64, 2a0e:aa07:e21c::/47 } counter accept
                iifname "enta*" counter drop
              }

              chain output {
                type filter hook output priority filter; policy accept;
                oifname "enta*" ip6 daddr != { fe80::/64, 2a0e:aa07:e21c::/47 } \
                  icmpv6 type time-exceeded counter drop
              }
            '';
          };
        };

        netns.enthalpy.bindMounts = {
          "/nix".readOnly = false;
          "/var".readOnly = false;
        };

        systemd.services.nix-daemon = {
          serviceConfig = mkMerge [
            config.netns.enthalpy.serviceConfig
            { ProtectSystem = mkForce false; }
          ];
          unitConfig = config.netns.enthalpy.unitConfig;
        };
      };
  };
}
