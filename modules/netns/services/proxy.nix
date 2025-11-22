{ self, lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets)
    filterAttrs
    listToAttrs
    nameValuePair
    mapAttrsToList
    ;
  inherit (lib.lists) optionals;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.strings) concatMapStringsSep;
  inherit (self.lib.misc) mkHardenedService;

  inboundOptions = _: {
    options = {
      netnsPath = mkOption {
        type = types.str;
        description = ''
          Path to the inbound network namespace.
        '';
      };
      listenAddress = mkOption {
        type = types.str;
        default = "[::1]";
        description = ''
          Address for reciving connections.
        '';
      };
      listenPort = mkOption {
        type = types.int;
        description = ''
          Port number for incoming connections.
        '';
      };
    };
  };

  proxyOptions = {
    enable = mkEnableOption "mixed proxy for other network namespaces";
    inbounds = mkOption {
      type = types.listOf (types.submodule inboundOptions);
      default = [ ];
      description = ''
        List of inbound configurations for the proxy.
      '';
    };
  };
in
{
  flake.nixosModules.netns =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.lib.netns) mkNetnsOption;

      mkProxyService =
        initNetns: name: cfg:
        nameValuePair "netns-${name}-proxy" (mkHardenedService {
          serviceConfig = mkMerge [
            cfg.serviceConfig
            {
              Type = "simple";
              Restart = "on-failure";
              RestartSec = 5;
              DynamicUser = true;
              ExecStart = "${getExe' pkgs.gost "gost"} ${
                concatMapStringsSep " " (
                  inbound:
                  ''-L "auto://${inbound.listenAddress}:${toString inbound.listenPort}?netns=${inbound.netnsPath}"''
                ) cfg.services.proxy.inbounds
              }";
              ProtectProc = "default";
              RestrictNamespaces = "net";
              AmbientCapabilities = [
                "CAP_SYS_ADMIN"
                "CAP_SYS_PTRACE"
              ];
              CapabilityBoundingSet = [
                "CAP_SYS_ADMIN"
                "CAP_SYS_PTRACE"
              ];
              SystemCallFilter = [ "@system-service" ];
            }
          ];
          unitConfig = cfg.unitConfig;
          environment = {
            GOST_LOGGER_LEVEL = "warn";
          };
          wantedBy = [
            "multi-user.target"
          ]
          ++ optionals (!initNetns) [
            "netns-${name}.service"
          ];
        });

      proxyEnabledNetns = filterAttrs (_: cfg: cfg.enable && cfg.services.proxy.enable) config.netns;
    in
    {
      options = {
        services.proxy = proxyOptions;

        netns = mkNetnsOption {
          options.services.proxy = proxyOptions;
        };
      };

      config = {
        systemd.services = listToAttrs (
          mapAttrsToList (mkProxyService false) proxyEnabledNetns
          ++ optionals (config.services.proxy.enable) [
            (mkProxyService true "init" {
              unitConfig = {
                After = [ "network-online.target" ];
                Wants = [ "network-online.target" ];
              };
              serviceConfig = { };
              services = {
                inherit (config.services) proxy;
              };
            })
          ]
        );
      };
    };
}
