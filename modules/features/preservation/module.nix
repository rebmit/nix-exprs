# Portions of this file are sourced from
# https://github.com/nix-community/preservation/blob/93416f4614ad2dfed5b0dcf12f27e57d27a5ab11/module.nix (MIT License)
{ lib, ... }:
let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) flatten;
  inherit (lib.modules) mkIf;
in
{
  flake.modules.nixos.preservation =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.passthru.preservation)
        mkRuleFileContent
        mkRegularMountUnits
        mkInitrdMountUnits
        mkRegularTmpfilesRules
        mkInitrdTmpfilesRules
        mkUserParentClosureTmpfilesRule
        mkInitrdTmpfilesService
        mkRegularTmpfilesService
        ;

      configPathSuffix = "preservation.conf";
      configPath = "/etc/${configPathSuffix}";

      cfg = config.preservation;
    in
    {
      config = mkIf cfg.enable {
        assertions = [
          {
            assertion = config.boot.initrd.systemd.enable;
            message = ''
              This module cannot be used with scripted initrd.
            '';
          }
        ];

        boot.initrd.systemd = {
          targets.initrd-preservation = {
            description = "Initrd Preservation Mounts";
            before = [ "initrd.target" ];
            wantedBy = [ "initrd.target" ];
          };
          contents."${configPath}".source = pkgs.writeText "preservation.conf" (
            mkRuleFileContent (mkInitrdTmpfilesRules cfg)
          );
          mounts = mkInitrdMountUnits cfg;
          services.systemd-tmpfiles-setup-preservation = mkInitrdTmpfilesService configPath cfg.persistentStoragePath;
        };

        systemd = {
          targets.preservation = {
            description = "Preservation Mounts";
            before = [ "sysinit.target" ];
            wantedBy = [ "sysinit.target" ];
          };
          mounts = mkRegularMountUnits cfg;
          services = {
            systemd-tmpfiles-setup-preservation =
              mkRegularTmpfilesService true configPath cfg.persistentStoragePath
                "";
            systemd-tmpfiles-resetup-preservation =
              mkRegularTmpfilesService false configPath cfg.persistentStoragePath
                config.environment.etc."${configPathSuffix}".source;
          };
        };

        environment.etc."${configPathSuffix}".source = pkgs.writeText "preservation.conf" (
          mkRuleFileContent (
            flatten (
              mkRegularTmpfilesRules cfg
              ++ mapAttrsToList (mkUserParentClosureTmpfilesRule cfg.persistentStoragePath) cfg.users
            )
          )
        );
      };
    };
}
