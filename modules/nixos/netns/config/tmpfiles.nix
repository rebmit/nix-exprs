{ lib, ... }:
let
  inherit (lib.attrsets)
    filterAttrs
    mapAttrsToList
    mapAttrs'
    nameValuePair
    ;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption;
in
{
  flake.modules.nixos.netns =
    {
      options,
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.lib.netns) mkNetnsOption mkTmpfilesRuleFileContent;

      enabledNetns = filterAttrs (_: cfg: cfg.enable) config.netns;
    in
    {
      options.netns = mkNetnsOption (
        { name, config, ... }:
        {
          _file = ./tmpfiles.nix;

          options = {
            tmpfiles = mkOption {
              inherit (options.systemd.tmpfiles.settings) type;
              default = { };
              description = ''
                Declare per-network namespace systemd-tmpfiles rules to
                create, delete, and clean up volatile and temporary files
                and directories.
              '';
            };
          };

          config = mkIf config.enable {
            unitConfig = {
              After = [ "netns-${name}-tmpfiles.service" ];
            };

            tmpfiles."00-netns-${name}" = {
              "/run".d = {
                mode = "0755";
                user = "root";
                group = "root";
              };
              "/tmp".q = {
                mode = "1777";
                user = "root";
                group = "root";
                age = "10d";
              };
            };

            confext."tmpfiles.d".source = pkgs.symlinkJoin {
              name = "tmpfiles.d";
              paths = mapAttrsToList (
                name: cfg: pkgs.writeTextDir "${name}.conf" (mkTmpfilesRuleFileContent cfg)
              ) config.tmpfiles;
            };
          };
        }
      );

      config = {
        systemd.services = mapAttrs' (
          name: cfg:
          nameValuePair "netns-${name}-tmpfiles" {
            serviceConfig = mkMerge [
              cfg.serviceConfig
              {
                Type = "oneshot";
                RemainAfterExit = true;
                ExecStart = "systemd-tmpfiles --create --remove";
                SuccessExitStatus = "DATAERR CANTCREAT";
              }
            ];
            after = [
              "netns-${name}.service"
              "netns-${name}-confext.service"
            ];
            partOf = [ "netns-${name}.service" ];
            requires = [ "netns-${name}.service" ];
            wantedBy = [
              "netns-${name}.service"
              "multi-user.target"
            ];
            restartTriggers = [ cfg.confext."tmpfiles.d".source ];
          }
        ) enabledNetns;
      };
    };
}
