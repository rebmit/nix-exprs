# Portions of this file are sourced from
# https://github.com/NickCao/flakes/blob/3b03efb676ea602575c916b2b8bc9d9cd13b0d85/modules/gravity/default.nix (MIT License)
{ self, lib, ... }:
let
  inherit (lib) types;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (self.lib.network.ipv6) cidrSubnet cidrHost;
in
{
  flake.modules.nixos."services/enthalpy" =
    { config, pkgs, ... }:
    let
      cfg = config.services.enthalpy;
      netnsCfg = config.netns.enthalpy;
    in
    {
      options.services.enthalpy.srv6 = {
        enable = mkEnableOption "segment routing over IPv6";
        prefix = mkOption {
          type = types.str;
          default = cidrSubnet 4 6 cfg.prefix;
          description = ''
            Prefix used for SRv6 actions.
          '';
        };
        table = mkOption {
          type = types.int;
          default = 500;
          description = ''
            The routing table used for local SIDs in enthalpy netns.
          '';
        };
        priority = mkOption {
          type = types.int;
          default = 500;
          description = ''
            Policy routing priority for the local SIDs table.
          '';
        };
        actions = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = ''
            List of SRv6 actions configured for this node.
          '';
        };
      };

      config = mkIf (cfg.enable && cfg.srv6.enable) {
        services.enthalpy.srv6.actions = [
          "${cidrHost 0 cfg.srv6.prefix} encap seg6local action End                dev enthalpy table localsid"
          "${cidrHost 1 cfg.srv6.prefix} encap seg6local action End.DT6 table main dev enthalpy table localsid"
        ];

        netns.enthalpy = {
          services.networkd = {
            config = {
              routeTables.localsid = cfg.srv6.table;
            };
            networks = {
              "20-lo" = {
                matchConfig.Name = "lo";
                routes = [
                  {
                    Type = "blackhole";
                    Destination = "::/0";
                    Table = netnsCfg.services.networkd.config.routeTables.localsid;
                  }
                ];
                routingPolicyRules = [
                  {
                    Priority = cfg.srv6.priority;
                    Family = "ipv6";
                    From = cfg.network;
                    To = cfg.srv6.prefix;
                    Table = netnsCfg.services.networkd.config.routeTables.localsid;
                  }
                ];
              };
            };
          };
        };

        # drop if systemd-networkd can do this in the future
        systemd.services.enthalpy-srv6 = {
          serviceConfig = mkMerge [
            netnsCfg.serviceConfig
            {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStartPre = "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --interface enthalpy";
              ExecStart = map (r: "${pkgs.iproute2}/bin/ip -6 r add ${r}") cfg.srv6.actions;
              ExecStop = map (r: "${pkgs.iproute2}/bin/ip -6 r del ${r}") cfg.srv6.actions;
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
