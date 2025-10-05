{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets)
    filterAttrs
    mapAttrs'
    nameValuePair
    mapAttrsToList
    ;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption;
in
{
  flake.modules.nixos.netns =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.passthru.netns)
        mkNetnsOption
        attrsToProperties
        evalSystemdService
        ;

      enabledNetns = filterAttrs (_: cfg: cfg.enable) config.netns;
    in
    {
      options.netns =
        mkNetnsOption (
          { name, config, ... }:
          {
            _file = ./common.nix;

            options = {
              enable = mkEnableOption "the network namespace" // {
                default = true;
              };
              netnsPath = mkOption {
                type = types.str;
                default = "/run/netns/${name}";
                readOnly = true;
                description = ''
                  Path to the network namespace, see {manpage}`ip-netns(8)`.
                '';
              };
              config = mkOption {
                type = types.submodule {
                  freeformType = (pkgs.formats.json { }).type;
                };
                default = { };
                description = ''
                  Systemd service configuration for entering the network namespace.
                '';
              };
              build = mkOption {
                type = types.submodule {
                  freeformType = types.lazyAttrsOf (types.uniq types.unspecified);
                };
                default = { };
                description = ''
                  Attribute set of derivations used to set up the network namespace.
                '';
              };
            };

            config = mkIf config.enable {
              config = {
                serviceConfig = {
                  NetworkNamespacePath = config.netnsPath;
                };
                after = [ "netns-${name}.service" ];
                partOf = [ "netns-${name}.service" ];
                wants = [ "netns-${name}.service" ];
                wantedBy = [
                  "netns-${name}.service"
                  "multi-user.target"
                ];
              };
            };
          }
        )
        // {
          default = { };
          description = ''
            Named network namespace configuration.
          '';
        };

      config = {
        systemd.services = mapAttrs' (
          name: _:
          nameValuePair "netns-${name}" {
            path = with pkgs; [ iproute2 ];
            script = ''
              ip netns add ${name}
            '';
            preStop = ''
              ip netns del ${name}
            '';
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            restartIfChanged = false;
            after = [
              "network-pre.target"
              "systemd-sysctl.service"
            ];
            wantedBy = [ "multi-user.target" ];
          }
        ) enabledNetns;

        environment.systemPackages =
          mapAttrsToList
            (
              name: cfg:
              let
                inherit (evalSystemdService cfg.config) unitConfig serviceConfig;
              in
              pkgs.writeShellApplication {
                name = "netns-run-${name}";
                text = ''
                  systemd-run --pipe --pty \
                    ${attrsToProperties unitConfig} \
                    ${attrsToProperties serviceConfig} \
                    --property="User=$USER" \
                    --same-dir \
                    --wait "$@"
                '';
              }
            )
            (
              if (enabledNetns != { }) then
                (
                  enabledNetns
                  // {
                    init.config = { };
                  }
                )
              else
                { }
            );
      };
    };
}
