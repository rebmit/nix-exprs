{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsToList filterAttrs optionalAttrs;
  inherit (lib.lists) all elem;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.options) mkOption mkEnableOption;
in
{
  unify.modules."home/preservation" = {
    nixos = {
      module =
        { config, unify, ... }:
        optionalAttrs
          (all (mod: elem mod unify.meta.closure) [
            "external/home-manager"
            "external/preservation"
          ])
          {
            home-manager.sharedModules = [
              (
                { config, osConfig }:
                {
                  options.preservation = {
                    enable = mkEnableOption "the preservation module";
                    directories = mkOption {
                      type = types.listOf (types.coercedTo types.str (d: { directory = d; }) types.anything);
                      default = [ ];
                      description = ''
                        Specify a list of directories that should be preserved for this user.
                        The paths are interpreted relative to the user's home directory.
                      '';
                    };
                    files = mkOption {
                      type = types.listOf (types.coercedTo types.str (f: { file = f; }) types.anything);
                      default = [ ];
                      description = ''
                        Specify a list of files that should be preserved for this user.
                        The paths are interpreted relative to the user's home directory.
                      '';
                    };
                    commonMountOptions = mkOption {
                      type = types.listOf (types.coercedTo types.str (n: { name = n; }) types.anything);
                      default = [ ];
                      description = ''
                        Specify a list of mount options that should be added to all files and directories
                        of this user, for which {option}`how` is set to `bindmount`.

                        See also the top level {option}`commonMountOptions` and the invdividual
                        {option}`mountOptions` that is available per file / directory.
                      '';
                    };
                  };

                  config = {
                    warnings = mkIf (config.preservation.enable && !osConfig.preservation.enable) [
                      ''
                        The preservation module is enabled in Home Manager but disabled system-wide.
                        As a result, the settings will not take effect.
                      ''
                    ];

                    preservation.enable = mkDefault osConfig.preservation.enable;
                  };
                }
              )
            ];

            preservation = mkMerge (
              mapAttrsToList (name: hmCfg: {
                users.${name} = {
                  home = hmCfg.home.homeDirectory;
                  inherit (hmCfg.preservation) directories files commonMountOptions;
                };
              }) (filterAttrs (_: hmCfg: hmCfg.preservation.enable) config.home-manager.users)
            );
          };
    };
  };
}
