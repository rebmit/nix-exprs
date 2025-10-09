# Portions of this file are sourced from
# https://github.com/NickCao/flakes/blob/3b03efb676ea602575c916b2b8bc9d9cd13b0d85/modules/gravity/default.nix (MIT License)
{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption;
  inherit (selfLib.network.ipv6) cidrHost;
  inherit (selfLib.misc) mkHardenedService;
in
{
  flake.modules.nixos.enthalpy =
    { config, pkgs, ... }:
    let
      cfg = config.services.enthalpy;
      netnsCfg = config.netns.enthalpy;
    in
    {
      options.services.enthalpy.exit = {
        enable = mkEnableOption "exit node";
        plat.enable = mkEnableOption "the PLAT component of 464XLAT" // {
          default = true;
        };
      };

      config = mkIf (cfg.enable && cfg.exit.enable) {
        # drop if systemd-networkd can do this in the future
        systemd.services.enthalpy-exit = {
          path = with pkgs; [ iproute2 ];
          script = ''
            ip link add host mtu 1400 address 02:00:00:00:00:01 type veth \
              peer enthalpy mtu 1400 address 02:00:00:00:00:02 netns /proc/1/ns/net
          '';
          preStop = ''
            ip link del host
          '';
          serviceConfig = mkMerge [
            netnsCfg.serviceConfig
            {
              Type = "oneshot";
              RemainAfterExit = true;
            }
          ];
          unitConfig = netnsCfg.unitConfig;
          wantedBy = [
            "netns-enthalpy.service"
            "multi-user.target"
          ];
        };

        netns.enthalpy = {
          services.networkd = {
            config = {
              routeTables.exit = 400;
            };
            networks = {
              "20-host" = {
                matchConfig.Name = "host";
                routes = [
                  {
                    Destination = "::/0";
                    Source = cfg.network;
                    Gateway = "fe80::ff:fe00:2";
                    GatewayOnLink = true;
                    Table = netnsCfg.services.networkd.config.routeTables.exit;
                  }
                ];
              };
            };
          };

          services.bird.config = ''
            protocol static {
              ipv6 sadr;
              route ${cfg.network} from ::/0 unreachable;
              route ::/0 from ${cfg.network} via fe80::ff:fe00:2 dev "host";
            }
          '';
        };

        services.enthalpy.srv6.actions = [
          "${cidrHost 2 cfg.srv6.prefix} encap seg6local action End.DT6 table exit dev enthalpy table localsid"
        ];

        systemd.network = {
          config = {
            networkConfig = {
              IPv4Forwarding = mkIf cfg.exit.plat.enable true;
              IPv6Forwarding = true;
            };
            routeTables.enthalpy = 400;
          };
          networks = {
            "20-enthalpy" = {
              matchConfig.Name = "enthalpy";
              routes = [
                {
                  Destination = cfg.network;
                  Gateway = "fe80::ff:fe00:1";
                  GatewayOnLink = true;
                  Table = config.systemd.network.config.routeTables.enthalpy;
                }
              ];
              routingPolicyRules = [
                {
                  Priority = 1000;
                  Family = "ipv6";
                  Table = config.systemd.network.config.routeTables.enthalpy;
                }
              ];
              linkConfig.RequiredForOnline = false;
            };
            "20-plat" = mkIf cfg.exit.plat.enable {
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
          };
        };

        networking.nftables = mkIf cfg.exit.plat.enable {
          enable = true;
          tables.plat = {
            family = "ip";
            content = ''
              chain forward {
                type filter hook forward priority filter; policy accept;
                iifname plat tcp flags syn tcp option maxseg size set 1200
                oifname plat tcp flags syn tcp option maxseg size set 1200
              }
            '';
          };
        };

        systemd.services.plat = mkIf cfg.exit.plat.enable (mkHardenedService {
          serviceConfig = {
            Type = "forking";
            Restart = "on-failure";
            RestartSec = 5;
            DynamicUser = true;
            ExecStart = "${getExe pkgs.tayga} --config ${pkgs.writeText "tayga.conf" ''
              tun-device plat
              ipv6-addr fc00::
              ipv4-addr 100.127.0.1
              prefix 64:ff9b::/96
              dynamic-pool 100.127.0.0/16
            ''}";
            CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
            AmbientCapabilities = [ "CAP_NET_ADMIN" ];
            PrivateDevices = false;
          };
          after = [ "network-pre.target" ];
          wantedBy = [ "multi-user.target" ];
        });
      };
    };
}
