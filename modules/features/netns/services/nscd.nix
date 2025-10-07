{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib.attrsets)
    filterAttrs
    mapAttrs'
    nameValuePair
    ;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption;
  inherit (selfLib.misc) mkHardenedService;
in
{
  flake.modules.nixos.netns =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.passthru.netns.lib)
        mkNetnsOption
        mkRuntimeDirectoryConfiguration
        ;

      nscdEnabledNetns = filterAttrs (_: cfg: cfg.enable && cfg.services.nscd.enable) config.netns;
    in
    {
      options.netns = mkNetnsOption (
        { name, config, ... }:
        {
          _file = ./nscd.nix;

          options.services.nscd = {
            enable = mkEnableOption "nscd" // {
              default = true;
            };
          };

          config = mkIf config.enable {
            unitConfig = {
              After = [ "netns-${name}-nscd.service" ];
            };
          };
        }
      );

      config = {
        systemd.services = mapAttrs' (
          name: cfg:
          nameValuePair "netns-${name}-nscd" (mkHardenedService {
            serviceConfig = mkMerge [
              cfg.serviceConfig
              (mkRuntimeDirectoryConfiguration name "nscd" "/run/nscd" "0755")
              {
                Type = "notify";
                Restart = "on-failure";
                RestartSec = 5;
                DynamicUser = true;
                ExecStart = "${pkgs.nsncd}/bin/nsncd";
              }
            ];
            environment = {
              LD_LIBRARY_PATH = config.system.nssModules.path;
            };
            after = [
              "netns-${name}.service"
              "netns-${name}-confext.service"
              "netns-${name}-sysctl.service"
            ];
            partOf = [ "netns-${name}.service" ];
            requires = [ "netns-${name}.service" ];
            wantedBy = [
              "netns-${name}.service"
              "multi-user.target"
            ];
          })
        ) nscdEnabledNetns;
      };
    };
}
