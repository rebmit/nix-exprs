# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/modules/system/boot/networkd.nix (MIT License)
{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib.attrsets)
    filterAttrs
    mapAttrs'
    nameValuePair
    ;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.strings) optionalString;
  inherit (selfLib.misc) mkHardenedService;
in
{
  flake.modules.nixos.netns =
    {
      options,
      config,
      utils,
      ...
    }:
    let
      inherit (config.passthru.netns.lib) mkNetnsOption mkRuntimeDirectoryConfiguration;
      inherit (utils.systemdUtils.lib) attrsToSection;
      inherit (utils.systemdUtils.network.units) netdevToUnit networkToUnit;

      mkUnit = f: def: {
        inherit (def) enable;
        text = f def;
      };

      mkUnitFiles =
        cfg:
        mapAttrs' (
          n: v:
          nameValuePair "systemd/network/${n}" {
            source = "${v.unit}/${n}";
          }
        ) cfg.units;

      renderConfig = def: {
        text = ''
          [Network]
          ${attrsToSection def.networkConfig}
        ''
        + optionalString (def.dhcpV4Config != { }) ''
          [DHCPv4]
          ${attrsToSection def.dhcpV4Config}
        ''
        + optionalString (def.dhcpV6Config != { }) ''
          [DHCPv6]
          ${attrsToSection def.dhcpV6Config}
        '';
      };

      networkdEnabledNetns = filterAttrs (
        _: cfg: cfg.enable && cfg.services.networkd.enable
      ) config.netns;
    in
    {
      options.netns = mkNetnsOption (
        { config, ... }:
        let
          cfg = config.services.networkd;
        in
        {
          _file = ./networkd.nix;

          options.services.networkd = {
            enable = mkEnableOption "networkd";
            netdevs = mkOption {
              inherit (options.systemd.network.netdevs) type;
              default = { };
              description = ''
                Definitions of systemd network devices.
              '';
            };
            networks = mkOption {
              inherit (options.systemd.network.networks) type;
              default = { };
              description = ''
                Definitions of systemd networks.
              '';
            };
            config = mkOption {
              inherit (options.systemd.network.config) type;
              default = { };
              description = ''
                Definitions of global systemd network config.
              '';
            };
            units = mkOption {
              inherit (options.systemd.network.units) type;
              internal = true;
              default = { };
              description = ''
                Definitions of systemd networkd units.
              '';
            };
          };

          config = mkIf (config.enable && cfg.enable) {
            services.networkd.units =
              mapAttrs' (n: v: nameValuePair "${n}.netdev" (mkUnit netdevToUnit v)) cfg.netdevs
              // mapAttrs' (n: v: nameValuePair "${n}.network" (mkUnit networkToUnit v)) cfg.networks;

            confext = mkMerge [
              (mkUnitFiles cfg)
              { "systemd/networkd.conf" = renderConfig cfg.config; }
            ];
          };
        }
      );

      config = {
        systemd.services = mapAttrs' (
          name: cfg:
          nameValuePair "netns-${name}-networkd" (mkHardenedService {
            serviceConfig = mkMerge [
              cfg.serviceConfig
              (mkRuntimeDirectoryConfiguration name "networkd" "/run/systemd/netif" "0755")
              {
                AmbientCapabilities = [
                  "CAP_NET_ADMIN"
                  "CAP_NET_BIND_SERVICE"
                  "CAP_NET_BROADCAST"
                  "CAP_NET_RAW"
                  "CAP_BPF"
                  "CAP_SYS_ADMIN"
                ];
                CapabilityBoundingSet = [
                  "CAP_NET_ADMIN"
                  "CAP_NET_BIND_SERVICE"
                  "CAP_NET_BROADCAST"
                  "CAP_NET_RAW"
                  "CAP_BPF"
                  "CAP_SYS_ADMIN"
                ];
                DeviceAllow = "char-* rw";
                DynamicUser = true;
                ExecStart = "${config.systemd.package}/lib/systemd/systemd-networkd";
                FileDescriptorStoreMax = 512;
                ProcSubset = "all";
                Restart = "on-failure";
                RestartKillSignal = "SIGUSR2";
                RestartSec = 0;
                RestrictAddressFamilies = [
                  "AF_UNIX"
                  "AF_NETLINK"
                  "AF_INET"
                  "AF_INET6"
                  "AF_PACKET"
                ];
                SystemCallFilter = [
                  "@system-service"
                  "bpf"
                ];
                Type = "notify-reload";
              }
            ];
            inherit (cfg) unitConfig;
            wantedBy = [
              "netns-${name}.service"
              "multi-user.target"
            ];
          })
        ) networkdEnabledNetns;
      };
    };
}
