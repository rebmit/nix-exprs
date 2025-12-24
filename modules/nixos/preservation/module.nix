# Portions of this file are sourced from
# https://github.com/nix-community/preservation/blob/93416f4614ad2dfed5b0dcf12f27e57d27a5ab11/module.nix (MIT License)
{ lib, ... }:
let
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) flatten;
  inherit (lib.modules) mkIf;
  inherit (lib.trivial) pipe;
in
{
  flake.modules.nixos.preservation =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.lib.preservation)
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
      persistentStoragePaths = mapAttrsToList (_: pcfg: pcfg.persistentStoragePath) cfg.preserveAt;
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
          contents."${configPath}".source = pipe cfg.preserveAt [
            (mapAttrsToList mkInitrdTmpfilesRules)
            flatten
            mkRuleFileContent
            (pkgs.writeText "preservation.conf")
          ];
          mounts = pipe cfg.preserveAt [
            (mapAttrsToList mkInitrdMountUnits)
            flatten
          ];
          services.systemd-tmpfiles-setup-preservation = mkInitrdTmpfilesService configPath persistentStoragePaths;
        };

        systemd = {
          targets.preservation = {
            description = "Preservation Mounts";
            before = [ "sysinit.target" ];
            wantedBy = [ "sysinit.target" ];
          };
          mounts = pipe cfg.preserveAt [
            (mapAttrsToList mkRegularMountUnits)
            flatten
          ];
          services = {
            systemd-tmpfiles-setup-preservation =
              mkRegularTmpfilesService true configPath persistentStoragePaths
                "";
            systemd-tmpfiles-resetup-preservation =
              mkRegularTmpfilesService false configPath persistentStoragePaths
                config.environment.etc."${configPathSuffix}".source;
          };
        };

        environment.etc."${configPathSuffix}".source = pipe cfg.preserveAt [
          (
            pcfgs:
            mapAttrsToList mkRegularTmpfilesRules pcfgs
            ++ mapAttrsToList (
              _: scfg: mapAttrsToList (mkUserParentClosureTmpfilesRule scfg.persistentStoragePath) scfg.users
            ) pcfgs
          )
          flatten
          mkRuleFileContent
          (pkgs.writeText "preservation.conf")
        ];
      };
    };
}
