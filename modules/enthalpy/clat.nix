# Portions of this file are sourced from
# https://github.com/NickCao/flakes/blob/3b03efb676ea602575c916b2b8bc9d9cd13b0d85/nixos/mainframe/gravity.nix (MIT License)
{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.strings) concatStringsSep;
  inherit (selfLib.network.ipv6) cidrHost;
in
{
  flake.modules.nixos.enthalpy =
    { config, pkgs, ... }:
    let
      cfg = config.services.enthalpy;
      netnsCfg = config.netns.enthalpy;
    in
    {
      options.services.enthalpy.clat = {
        enable = mkEnableOption "the CLAT component of 464XLAT";
        address = mkOption {
          type = types.str;
          default = cidrHost 2 cfg.prefix;
          description = ''
            IPv6 address used for CLAT as the mapped source address
            for outgoing packets from this node.
          '';
        };
        prefix = mkOption {
          type = types.str;
          default = "64:ff9b::/96";
          description = ''
            IPv6 prefix used for the PLAT component of 464XLAT.
          '';
        };
        segment = mkOption {
          type = types.listOf types.str;
          description = ''
            SRv6 segments to reach the PLAT gateway.
          '';
        };
      };

      config = mkIf (cfg.enable && cfg.clat.enable) {
        netns.enthalpy = {
          services.tayga.clat = {
            ipv4Address = "192.0.0.1";
            ipv6Address = "fc00::";
            prefix = cfg.clat.prefix;
            mappings."192.0.0.2" = cfg.clat.address;
          };

          services.networkd.networks = {
            "20-clat" = {
              matchConfig.Name = "clat";
              addresses = [
                { Address = "192.0.0.2/32"; }
              ];
              routes = [
                { Destination = "${cfg.clat.address}/128"; }
                {
                  Destination = "0.0.0.0/0";
                  PreferredSource = "192.0.0.2";
                }
              ];
            };
          };
        };

        # drop if systemd-networkd can do this in the future
        systemd.services.enthalpy-clat = {
          serviceConfig = mkMerge [
            netnsCfg.serviceConfig
            {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStartPre = "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --interface enthalpy";
              ExecStart = "${pkgs.iproute2}/bin/ip r replace ${cfg.clat.prefix} from ${cfg.clat.address} encap seg6 mode encap segs ${concatStringsSep "," cfg.clat.segment} dev enthalpy mtu 1280";
              ExecStop = "${pkgs.iproute2}/bin/ip r del ${cfg.clat.prefix} from ${cfg.clat.address}";
            }
          ];
          unitConfig = netnsCfg.unitConfig;
          wantedBy = [
            "netns-enthalpy.service"
            "multi-user.target"
          ];
        };
      };
    };
}
