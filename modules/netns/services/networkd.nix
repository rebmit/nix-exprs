# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/modules/system/boot/networkd.nix (MIT License)
{ self, lib, ... }:
let
  inherit (lib.attrsets)
    filterAttrs
    mapAttrs'
    nameValuePair
    mapAttrsToList
    attrValues
    ;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.strings) optionalString concatStringsSep hasSuffix;
  inherit (self.lib.misc) mkHardenedService;
in
{
  flake.nixosModules.netns =
    {
      options,
      config,
      utils,
      ...
    }:
    let
      inherit (config.lib.netns) mkNetnsOption mkRuntimeDirectoryConfiguration;
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
          unitFiles = mkUnitFiles cfg;
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
              unitFiles
              { "systemd/networkd.conf" = renderConfig cfg.config; }
              {
                "iproute2/rt_tables.d/networkd.conf".text = ''
                  ${concatStringsSep "\n" (
                    mapAttrsToList (name: number: "${toString number} ${name}") cfg.config.routeTables
                  )}
                '';
              }
            ];

            passthru.networkd = {
              inherit unitFiles;
            };
          };
        }
      );

      config = {
        systemd.services = mapAttrs' (
          name: cfg:
          let
            inherit (cfg.passthru.networkd) unitFiles;

            isReloadableUnitFileName = unitFileName: hasSuffix ".network" unitFileName;
            reloadableUnitFiles = filterAttrs (k: _: isReloadableUnitFileName k) unitFiles;
            nonReloadableUnitFiles = filterAttrs (k: _: !isReloadableUnitFileName k) unitFiles;
            unitFileSources = unitFiles: map (x: x.source) (attrValues unitFiles);
          in
          nameValuePair "netns-${name}-networkd" (mkHardenedService {
            serviceConfig = mkMerge [
              cfg.serviceConfig
              (mkRuntimeDirectoryConfiguration {
                netns = name;
                service = "networkd";
                runtimeDirectory = "/run/systemd/netif";
                runtimeDirectoryMode = "0755";
                runtimeDirectoryPreserve = true;
                runtimeDirectoryPreserveMode = "0755";
              })
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
                TemporaryFileSystem = [ "/run/dbus" ];
                Type = "notify-reload";
              }
            ];
            unitConfig = cfg.unitConfig;
            wantedBy = [
              "netns-${name}.service"
              "multi-user.target"
            ];
            reloadTriggers = unitFileSources reloadableUnitFiles;
            restartTriggers = unitFileSources nonReloadableUnitFiles ++ [
              cfg.confext."systemd/networkd.conf".source
            ];
            stopIfChanged = false;
          })
        ) networkdEnabledNetns;
      };
    };
}
