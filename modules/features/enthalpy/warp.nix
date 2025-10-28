# Portions of this file are sourced from
# https://github.com/NickCao/flakes/blob/3b03efb676ea602575c916b2b8bc9d9cd13b0d85/modules/gravity/default.nix (MIT License)
{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) singleton;
  inherit (selfLib.network.ipv6) cidrHost;
  inherit (selfLib.misc) mkHardenedService;
in
{
  flake.nixosModules.enthalpy =
    { config, pkgs, ... }:
    let
      cfg = config.services.enthalpy;
      netnsCfg = config.netns.enthalpy;
      warpNetnsCfg = config.netns.warp;
    in
    {
      options.services.enthalpy.warp = {
        enable = mkEnableOption "warp integration";
        prefixes = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = ''
            List of prefixes that are routed to warp by default.
          '';
        };
        table = mkOption {
          type = types.int;
          default = 401;
          description = ''
            The routing table used for warp routes in enthalpy netns.
          '';
        };
        plat.enable = mkEnableOption "the PLAT component of 464XLAT" // {
          default = true;
        };
      };

      config = mkIf (cfg.enable && cfg.warp.enable) {
        netns.warp = {
          sysctl = {
            "net.ipv6.conf.all.forwarding" = 1;
            "net.ipv6.conf.default.forwarding" = 1;
            "net.ipv4.conf.all.forwarding" = 1;
            "net.ipv4.conf.default.forwarding" = 1;
          };

          nftables.tables.warp = {
            family = "inet";
            content = ''
              chain forward {
                type filter hook forward priority filter; policy accept;
                iifname warp tcp flags syn tcp option maxseg size set 1200
                oifname warp tcp flags syn tcp option maxseg size set 1200
              }

              chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
                oifname warp counter masquerade
              }
            '';
          };

          services.nscd.enable = false;

          services.networkd = {
            enable = true;
            networks = {
              "20-enthalpy" = {
                matchConfig.Name = "enthalpy";
                routes = [
                  {
                    Destination = cfg.network;
                    Gateway = "fe80::ff:fe00:1";
                    GatewayOnLink = true;
                  }
                ];
                linkConfig.RequiredForOnline = false;
              };
              "20-plat" = mkIf cfg.warp.plat.enable {
                matchConfig.Name = "plat";
                routes = [
                  {
                    Destination = "64:ff9b::/96";
                    Source = cfg.network;
                  }
                  { Destination = "100.127.0.0/16"; }
                ];
                networkConfig.LinkLocalAddressing = false;
                linkConfig.RequiredForOnline = false;
              };
              "20-warp" = {
                matchConfig.Name = "warp";
                routes = [
                  { Destination = "0.0.0.0/0"; }
                  { Destination = "::/0"; }
                ];
              };
            };
          };

          services.tayga.plat = mkIf cfg.warp.plat.enable {
            ipv6Address = "fc00::";
            ipv4Address = "100.127.0.1";
            prefix = "64:ff9b::/96";
            dynamicPool = "100.127.0.0/16";
          };
        };

        netns.enthalpy = {
          netdevs.warp = {
            kind = "veth";
            mtu = 1400;
            address = "02:00:00:00:00:01";
            extraArgs.peer = {
              name = "enthalpy";
              mtu = 1400;
              address = "02:00:00:00:00:02";
              netns = warpNetnsCfg.netnsPath;
            };
          };

          services.networkd = {
            config = {
              routeTables.warp = cfg.warp.table;
            };
            networks = {
              "20-warp" = {
                matchConfig.Name = "warp";
                routes =
                  singleton {
                    Destination = "::/0";
                    Source = cfg.network;
                    Gateway = "fe80::ff:fe00:2";
                    GatewayOnLink = true;
                    Table = netnsCfg.services.networkd.config.routeTables.warp;
                  }
                  ++ map (p: {
                    Destination = p;
                    Source = cfg.network;
                    Gateway = "fe80::ff:fe00:2";
                    GatewayOnLink = true;
                  }) cfg.warp.prefixes;
              };
            };
          };
        };

        services.enthalpy.srv6.actions = [
          "${cidrHost 3 cfg.srv6.prefix} encap seg6local action End.DT6 table warp dev enthalpy table localsid"
        ];

        systemd.services.cloudflare-warp-config = mkHardenedService {
          path = with pkgs; [ wgcf ];
          script = ''
            if [ ! -f $STATE_DIRECTORY/wgcf-account.toml ]; then
              wgcf register --accept-tos --config $STATE_DIRECTORY/wgcf-account.toml
            fi
            if [ ! -f $STATE_DIRECTORY/wgcf-profile.conf ]; then
              wgcf generate --config $STATE_DIRECTORY/wgcf-account.toml --profile $STATE_DIRECTORY/wgcf-profile.conf
            fi
            sed '/^Address/d; /^DNS/d; /^MTU/d' $STATE_DIRECTORY/wgcf-profile.conf > $STATE_DIRECTORY/wg.conf
            sed '/^Address/!d' $STATE_DIRECTORY/wgcf-profile.conf > $STATE_DIRECTORY/address.conf
          '';
          serviceConfig = mkMerge [
            netnsCfg.serviceConfig
            {
              Type = "oneshot";
              RemainAfterExit = true;
              StateDirectory = "warp";
              User = "cloudflare-warp";
              Restart = "on-failure";
              RestartSec = 5;
            }
          ];
          unitConfig = netnsCfg.unitConfig;
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
        };

        systemd.services.cloudflare-warp-netdev = {
          path = with pkgs; [
            wireguard-tools
            iproute2
            gawk
          ];
          preStart = ''
            ip link del tmp-warp || true
            ip -n warp link del tmp-warp || true
            ip -n warp link del warp || true
          '';
          script = ''
            ip link add tmp-warp mtu 1280 type wireguard
            ip link set tmp-warp netns warp
            ip -n warp link set tmp-warp name warp
            ip netns exec warp wg setconf warp /var/lib/warp/wg.conf
            awk -F'[ =,]' '/^Address/ {for (i=2; i<=NF; i++) if ($i ~ /^[0-9]/) print $i}' \
              /var/lib/warp/address.conf | xargs -I {} ip -n warp addr add {} dev warp
            ip -n warp link set warp up
          '';
          preStop = ''
            ip -n warp link del warp
          '';
          serviceConfig = mkMerge [
            netnsCfg.serviceConfig
            {
              BindReadOnlyPaths = [ "/run/netns" ];
              Type = "oneshot";
              RemainAfterExit = true;
              Restart = "on-failure";
              RestartSec = 5;
            }
          ];
          unitConfig = netnsCfg.unitConfig;
          after = [
            "netns-warp.service"
            "cloudflare-warp-config.service"
          ];
          partOf = [
            "netns-warp.service"
            "cloudflare-warp-config.service"
          ];
          requires = [
            "netns-warp.service"
            "cloudflare-warp-config.service"
          ];
          wantedBy = [ "multi-user.target" ];
        };

        users.users.cloudflare-warp = {
          group = "cloudflare-warp";
          isSystemUser = true;
        };

        users.groups.cloudflare-warp = { };
      };
    };
}
