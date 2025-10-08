{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets)
    filterAttrs
    mapAttrs'
    nameValuePair
    mapAttrsToList
    ;
  inherit (lib.lists) optionals;
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
      inherit (config.passthru.netns.lib) mkNetnsOption mkNetnsRunWrapper;

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
              serviceConfig = mkOption {
                type = types.submodule {
                  freeformType = (pkgs.formats.json { }).type;
                };
                default = { };
                description = ''
                  Systemd service configuration applied to services running inside
                  this network namespace.
                '';
              };
              unitConfig = mkOption {
                type = types.submodule {
                  freeformType = (pkgs.formats.json { }).type;
                };
                default = { };
                description = ''
                  Systemd unit configuration applied to services running inside
                  this network namespace.
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
              passthru = mkOption {
                visible = false;
                description = ''
                  You can put whatever you want here.
                '';
              };
            };

            config = mkIf config.enable {
              serviceConfig = {
                NetworkNamespacePath = config.netnsPath;
              };

              unitConfig = {
                After = [ "netns-${name}.service" ];
                PartOf = [ "netns-${name}.service" ];
                Requires = [ "netns-${name}.service" ];
              };

              build = {
                netnsRunWrapper = mkNetnsRunWrapper name config;
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
              ip -n ${name} link set lo up
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
          mapAttrsToList (_name: cfg: cfg.build.netnsRunWrapper) enabledNetns
          ++ (optionals (enabledNetns != { }) [ (mkNetnsRunWrapper "init" { }) ]);
      };
    };
}
