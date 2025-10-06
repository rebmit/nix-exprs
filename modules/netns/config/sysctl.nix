# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/modules/config/sysctl.nix (MIT License)
{ lib, ... }:
let
  inherit (lib.attrsets)
    filterAttrs
    mapAttrs
    mapAttrs'
    nameValuePair
    mapAttrsToList
    ;
  inherit (lib.modules) mkDefault mkIf mkMerge;
  inherit (lib.options) mkOption;
  inherit (lib.strings) hasPrefix concatStrings optionalString;
  inherit (lib.trivial) isBool;
in
{
  flake.modules.nixos.netns =
    {
      options,
      config,
      ...
    }:
    let
      inherit (config.passthru.netns.lib) mkNetnsOption;

      enabledNetns = filterAttrs (_: cfg: cfg.enable) config.netns;
    in
    {
      options.netns = mkNetnsOption (
        { name, config, ... }:
        {
          _file = ./sysctl.nix;

          options = {
            sysctl = mkOption {
              inherit (options.boot.kernel.sysctl) type;
              default = { };
              apply =
                sysctl:
                mapAttrs (
                  name: value:
                  if hasPrefix "net." name then
                    value
                  else
                    throw "Invalid sysctl key '${name}': must start with 'net.'"
                ) sysctl;
              description = ''
                Per-network namespace runtime parameters of the Linux kernel,
                configurable via {manpage}`sysctl(8)`.
              '';
            };
          };

          config = mkIf config.enable {
            sysctl = {
              "net.ipv6.conf.all.forwarding" = mkDefault 0;
              "net.ipv4.conf.all.forwarding" = mkDefault 0;
              "net.ipv6.conf.default.forwarding" = mkDefault 0;
              "net.ipv4.conf.default.forwarding" = mkDefault 0;
              "net.ipv4.ping_group_range" = mkDefault "0 2147483647";
            };

            unitConfig = {
              After = [ "netns-${name}-sysctl.service" ];
            };

            confext."sysctl.d/60-netns.conf".text = concatStrings (
              mapAttrsToList (
                n: v: optionalString (v != null) "${n}=${if isBool v && !v then "0" else toString v}\n"
              ) config.sysctl
            );
          };
        }
      );

      config = {
        systemd.services = mapAttrs' (
          name: cfg:
          nameValuePair "netns-${name}-sysctl" {
            serviceConfig = mkMerge [
              cfg.serviceConfig
              {
                Type = "oneshot";
                RemainAfterExit = true;
                NetworkNamespacePath = cfg.netnsPath;
                ExecStart = "${config.systemd.package}/lib/systemd/systemd-sysctl";
              }
            ];
            after = [
              "netns-${name}.service"
              "netns-${name}-confext.service"
              "systemd-modules-load.service"
              "systemd-sysctl.service"
            ];
            partOf = [ "netns-${name}.service" ];
            requires = [ "netns-${name}.service" ];
            wantedBy = [
              "netns-${name}.service"
              "multi-user.target"
            ];
            restartTriggers = [ cfg.confext."sysctl.d/60-netns.conf".source ];
          }
        ) enabledNetns;
      };
    };
}
