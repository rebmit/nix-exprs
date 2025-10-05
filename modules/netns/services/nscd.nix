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
      inherit (config.passthru.netns)
        mkNetnsOption
        mkRuntimeDirectory
        mkRuntimeDirectoryPath
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
            config = {
              serviceConfig = {
                BindPaths = mkIf config.services.nscd.enable [
                  "${mkRuntimeDirectoryPath name "nscd"}:/run/nscd:norbind"
                ];
                TemporaryFileSystem = mkIf (!config.services.nscd.enable) [ "/run/nscd" ];
              };
            };
          };
        }
      );

      config = mkMerge [
        {
          systemd.tmpfiles.settings."20-nscd" = {
            "/run/nscd".d = {
              mode = "0755";
              inherit (config.services.nscd) user;
              inherit (config.services.nscd) group;
            };
          };

          systemd.services.nscd.serviceConfig = mkIf config.services.nscd.enable {
            RuntimeDirectory = "nscd";
            RuntimeDirectoryPreserve = true;
          };
        }

        {
          systemd.tmpfiles.settings."20-nscd" = mapAttrs' (
            name: _: nameValuePair (mkRuntimeDirectoryPath name "nscd") { d = { }; }
          ) nscdEnabledNetns;

          systemd.services = mapAttrs' (
            name: cfg:
            nameValuePair "netns-${name}-nscd" (
              mkHardenedService (mkMerge [
                cfg.config
                {
                  serviceConfig = {
                    Type = "notify";
                    Restart = "on-failure";
                    RestartSec = 5;
                    DynamicUser = true;
                    RuntimeDirectory = mkRuntimeDirectory name "nscd";
                    RuntimeDirectoryPreserve = true;
                    ExecStart = "${pkgs.nsncd}/bin/nsncd";
                  };
                  environment = {
                    LD_LIBRARY_PATH = config.system.nssModules.path;
                    NSNCD_SOCKET_PATH = "${mkRuntimeDirectoryPath name "nscd"}/socket";
                  };
                }
              ])
            )
          ) nscdEnabledNetns;
        }
      ];
    };
}
