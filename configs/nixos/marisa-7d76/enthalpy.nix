{ lib, ... }:
let
  inherit (lib.modules) mkMerge mkForce;
in
{
  flake.unify.configs.nixos.marisa-7d76 = {
    meta = {
      includes = [ "services/enthalpy/common" ];
    };

    module =
      { config, ... }:
      {
        services.enthalpy = {
          ipsec = {
            interfaces = [ "enp14s0" ];
          };
          clat = {
            enable = true;
            segment = [ "2a0e:aa07:e21c:5866::3" ];
          };
        };

        netns.enthalpy.tmpfiles."20-graphics-driver" = config.systemd.tmpfiles.settings.graphics-driver;

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

        systemd.services."user@${toString config.users.users.rebmit.uid}" = {
          serviceConfig = mkMerge [
            config.netns.enthalpy.serviceConfig
            {
              ProtectSystem = mkForce false;
              BindPaths = [
                "/home:/home:rbind"
                "/root:/root:rbind"
                "/run/dbus:/run/dbus:rbind"
                "/run/pipewire:/run/pipewire:rbind"
                "/run/pulse:/run/pulse:rbind"
              ];
            }
          ];
          unitConfig = config.netns.enthalpy.unitConfig;
          overrideStrategy = "asDropin";
          restartIfChanged = false;
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

        services.proxy = {
          enable = true;
          inbounds = [
            {
              netnsPath = config.netns.enthalpy.netnsPath;
              listenPort = 3000;
            }
          ];
        };
      };
  };
}
