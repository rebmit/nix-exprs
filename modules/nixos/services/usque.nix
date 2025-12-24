{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkPackageOption mkOption;
in
{
  flake.modules.nixos."services/usque" =
    {
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.services.usque;
    in
    {
      options.services.usque = {
        enable = mkEnableOption "usque";

        package = mkPackageOption pkgs "usque" { };

        interfaceName = mkOption {
          type = types.str;
          default = "warp0";
          description = ''
            Name of the tunnel interface.
          '';
        };
      };

      config = mkIf cfg.enable {
        systemd.services.usque = {
          path = with pkgs; [
            usque
            iproute2
          ];
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          script = ''
            if [ ! -f "$STATE_DIRECTORY/config.json" ]; then
              usque register --accept-tos --config "$STATE_DIRECTORY/config.json"
            fi

            exec usque nativetun --config "$STATE_DIRECTORY/config.json" --interface-name "${cfg.interfaceName}"
          '';
          serviceConfig = {
            AmbientCapabilities = [ "CAP_NET_ADMIN" ];
            CapabilityBoundingSet = [ "CAP_NET_ADMIN" ];
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            NoNewPrivileges = true;
            PrivateMounts = true;
            PrivateTmp = true;
            ProcSubset = "pid";
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";
            RemoveIPC = true;
            RestrictAddressFamilies = [
              "AF_NETLINK"
              "AF_INET"
              "AF_INET6"
            ];
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            StateDirectory = "usque";
            SystemCallArchitectures = "native";
            SystemCallErrorNumber = "EPERM";
            SystemCallFilter = [
              "@system-service"
              "~@resources"
              "~@privileged"
            ];
            UMask = "0077";
          };
        };
      };
    };
}
