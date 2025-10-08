# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/modules/system/boot/resolved.nix (MIT License)
{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets)
    filterAttrs
    mapAttrs'
    nameValuePair
    ;
  inherit (lib.modules) mkIf mkMerge mkOrder;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.strings) optionalString concatStringsSep;
  inherit (selfLib.misc) mkHardenedService;
in
{
  flake.modules.nixos.netns =
    { config, ... }:
    let
      inherit (config.passthru.netns.lib) mkNetnsOption mkRuntimeDirectoryConfiguration;

      resolvedEnabledNetns = filterAttrs (
        _: cfg: cfg.enable && cfg.services.resolved.enable
      ) config.netns;
    in
    {
      options.netns = mkNetnsOption (
        { config, ... }:
        let
          cfg = config.services.resolved;
        in
        {
          _file = ./resolved.nix;

          options.services.resolved = {
            enable = mkEnableOption "resolved";
            dns = mkOption {
              type = types.nullOr (types.listOf types.str);
              default = null;
              description = ''
                A list of IPv4 and IPv6 addresses to use as the system DNS servers.
              '';
            };
            fallbackDns = mkOption {
              type = types.nullOr (types.listOf types.str);
              default = null;
              description = ''
                A list of IPv4 and IPv6 addresses to use as the fallback DNS servers.
              '';
            };
            domains = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = ''
                A list of domains. These domains are used as search suffixes
                when resolving single-label host names (domain names which
                contain no dot), in order to qualify them into fully-qualified
                domain names (FQDNs).
              '';
            };
            llmnr = mkOption {
              type = types.enum [
                "true"
                "resolve"
                "false"
              ];
              default = "true";
              description = ''
                Controls Link-Local Multicast Name Resolution support
                (RFC 4795) on the local host.

                If set to
                - `"true"`: Enables full LLMNR responder and resolver support.
                - `"false"`: Disables both.
                - `"resolve"`: Only resolution support is enabled, but responding is disabled.
              '';
            };
            dnssec = mkOption {
              type = types.enum [
                "true"
                "allow-downgrade"
                "false"
              ];
              default = "true";
              description = ''
                If set to
                - `"true"`:
                    all DNS lookups are DNSSEC-validated locally (excluding
                    LLMNR and Multicast DNS). Note that this mode requires a
                    DNS server that supports DNSSEC. If the DNS server does
                    not properly support DNSSEC all validations will fail.
                - `"allow-downgrade"`:
                    DNSSEC validation is attempted, but if the server does not
                    support DNSSEC properly, DNSSEC mode is automatically
                    disabled. Note that this mode makes DNSSEC validation
                    vulnerable to "downgrade" attacks, where an attacker might
                    be able to trigger a downgrade to non-DNSSEC mode by
                    synthesizing a DNS response that suggests DNSSEC was not
                    supported.
                - `"false"`: DNS lookups are not DNSSEC validated.
              '';
            };
            dnsovertls = mkOption {
              type = types.enum [
                "true"
                "opportunistic"
                "false"
              ];
              default = "opportunistic";
              description = ''
                If set to
                - `"true"`:
                    all DNS lookups will be encrypted. This requires
                    that the DNS server supports DNS-over-TLS and
                    has a valid certificate. If the hostname was specified
                    via the `address#hostname` format in {option}`services.resolved.domains`
                    then the specified hostname is used to validate its certificate.
                - `"opportunistic"`:
                    all DNS lookups will attempt to be encrypted, but will fallback
                    to unecrypted requests if the server does not support DNS-over-TLS.
                    Note that this mode does allow for a malicious party to conduct a
                    downgrade attack by immitating the DNS server and pretending to not
                    support encryption.
                - `"false"`:
                    all DNS lookups are done unencrypted.
              '';
            };
            extraConfig = mkOption {
              type = types.lines;
              default = "";
              description = ''
                Extra config to append to resolved.conf.
              '';
            };
          };

          config = mkIf (config.enable && cfg.enable) {
            services.nscd.enable = true;

            nssDatabases.hosts = (mkOrder 501 [ "resolve [!UNAVAIL=return]" ]);

            confext = {
              "systemd/resolved.conf".text = ''
                [Resolve]
                ${optionalString (cfg.dns != null) "DNS=${concatStringsSep " " cfg.dns}"}
                ${optionalString (cfg.fallbackDns != null) "FallbackDNS=${concatStringsSep " " cfg.fallbackDns}"}
                ${optionalString (cfg.domains != [ ]) "Domains=${concatStringsSep " " cfg.domains}"}
                LLMNR=${cfg.llmnr}
                DNSSEC=${cfg.dnssec}
                DNSOverTLS=${cfg.dnsovertls}
                ${cfg.extraConfig}
              '';
              "resolv.conf".source = "/run/systemd/resolve/stub-resolv.conf";
            };
          };
        }
      );

      config = {
        systemd.services = mapAttrs' (
          name: cfg:
          nameValuePair "netns-${name}-resolved" (mkHardenedService {
            serviceConfig = mkMerge [
              cfg.serviceConfig
              (mkRuntimeDirectoryConfiguration {
                netns = name;
                service = "resolved";
                runtimeDirectory = "/run/systemd/resolve";
                runtimeDirectoryMode = "0755";
                runtimeDirectoryPreserve = true;
                runtimeDirectoryPreserveMode = "0755";
              })
              {
                AmbientCapabilities = [
                  "CAP_NET_RAW"
                  "CAP_NET_BIND_SERVICE"
                ];
                CapabilityBoundingSet = [
                  "CAP_NET_RAW"
                  "CAP_NET_BIND_SERVICE"
                ];
                DynamicUser = true;
                ExecStart = "${config.systemd.package}/lib/systemd/systemd-resolved";
                ProtectHostname = false;
                ProcSubset = "all";
                Restart = "always";
                RestartSec = 0;
                RestrictAddressFamilies = [
                  "AF_UNIX"
                  "AF_NETLINK"
                  "AF_INET"
                  "AF_INET6"
                ];
                SystemCallFilter = [ "@system-service" ];
                TemporaryFileSystem = [ "/run/dbus" ];
                Type = "notify-reload";
              }
            ];
            unitConfig = cfg.unitConfig;
            wantedBy = [
              "netns-${name}.service"
              "multi-user.target"
            ];
            reloadTriggers = [ cfg.confext."systemd/resolved.conf".source ];
            stopIfChanged = false;
          })
        ) resolvedEnabledNetns;
      };
    };
}
