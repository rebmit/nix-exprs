# Portions of this file are sourced from
# https://github.com/nix-community/preservation/blob/93416f4614ad2dfed5b0dcf12f27e57d27a5ab11/options.nix (MIT License)
{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption mkEnableOption;
in
{
  flake.nixosModules.preservation =
    { config, ... }:
    let
      mountOption = types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = ''
              Specify the name of the mount option.
            '';
          };
          value = mkOption {
            type = with types; nullOr str;
            default = null;
            description = ''
              Optionally specify a value for the mount option.
            '';
          };
        };
      };

      directoryPath =
        {
          defaultOwner,
          defaultGroup,
          defaultMode,
          ...
        }:
        {
          options = {
            directory = mkOption {
              type = types.str;
              description = ''
                Specify the path to the directory that should be preserved.
              '';
            };
            user = mkOption {
              type = types.str;
              default = defaultOwner;
              description = ''
                Specify the user that owns the directory.
              '';
            };
            group = mkOption {
              type = types.str;
              default = defaultGroup;
              description = ''
                Specify the group that owns the directory.
              '';
            };
            mode = mkOption {
              type = types.str;
              default = defaultMode;
              description = ''
                Specify the access mode of the directory.
                See the section `Mode` in {manpage}`tmpfiles.d(5)` for more information.
              '';
            };
            mountOptions = mkOption {
              type = with types; listOf (coercedTo str (n: { name = n; }) mountOption);
              description = ''
                Specify a list of mount options that should be used for this directory.
                By default, `bind` and `X-fstrim.notrim` are added,
                use `mkForce` to override these if needed.
                See also {manpage}`fstrim(8)`.
              '';
            };
            inInitrd = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Whether to prepare preservation of this directory in initrd.

                ::: {.important}
                Note that both owner and group for this directory need to be
                available in the initrd for permissions to be set correctly.
                :::
              '';
            };
          };

          config = {
            mountOptions = [
              "bind"
              "X-fstrim.notrim" # see fstrim(8)
            ];
          };
        };

      filePath =
        {
          defaultOwner,
          defaultGroup,
          defaultMode,
          ...
        }:
        {
          options = {
            file = mkOption {
              type = types.str;
              description = ''
                Specify the path to the file that should be preserved.
              '';
            };
            user = mkOption {
              type = types.str;
              default = defaultOwner;
              description = ''
                Specify the user that owns the file.
              '';
            };
            group = mkOption {
              type = types.str;
              default = defaultGroup;
              description = ''
                Specify the group that owns the file.
              '';
            };
            mode = mkOption {
              type = types.str;
              default = defaultMode;
              description = ''
                Specify the access mode of the file.
                See the section `Mode` in {manpage}`tmpfiles.d(5)` for more information.
              '';
            };
            mountOptions = mkOption {
              type = with types; listOf (coercedTo str (o: { name = o; }) mountOption);
              description = ''
                Specify a list of mount options that should be used for this file.
                These options are only used when {option}`how` is set to `bindmount`.
                By default, `bind` is added,
                use `mkForce` to override this if needed.
              '';
            };
            inInitrd = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Whether to prepare preservation of this file in the initrd.

                ::: {.important}
                Note that both owner and group for this file need to be
                available in the initrd for permissions to be set correctly.
                :::
              '';
            };
          };

          config = {
            mountOptions = [
              "bind"
            ];
          };
        };

      userModule =
        attrs@{ name, ... }:
        {
          options = {
            username = mkOption {
              type = with types; passwdEntry str;
              default = name;
              description = ''
                Specify the user for which the {option}`directories` and {option}`files`
                should be persisted. Defaults to the name of the parent attribute set.
              '';
            };
            home = mkOption {
              type = with types; passwdEntry path;
              default = config.users.users.${attrs.config.username}.home;
              description = ''
                Specify the path to the user's home directory.
              '';
            };
            directories = mkOption {
              type =
                with types;
                listOf (
                  coercedTo str (d: { directory = d; }) (submodule [
                    {
                      _module.args = rec {
                        defaultOwner = attrs.config.username;
                        defaultGroup = config.users.users.${defaultOwner}.group;
                        defaultMode = "0700";
                      };
                      mountOptions = attrs.config.commonMountOptions;
                    }
                    directoryPath
                  ])
                );
              default = [ ];
              apply = map (d: d // { directory = "${attrs.config.home}/${d.directory}"; });
              description = ''
                Specify a list of directories that should be preserved for this user.
                The paths are interpreted relative to {option}`home`.
              '';
            };
            files = mkOption {
              type =
                with types;
                listOf (
                  coercedTo str (f: { file = f; }) (submodule [
                    {
                      _module.args = rec {
                        defaultOwner = attrs.config.username;
                        defaultGroup = config.users.users.${defaultOwner}.group;
                        defaultMode = "0600";
                      };
                      mountOptions = attrs.config.commonMountOptions;
                    }
                    filePath
                  ])
                );
              default = [ ];
              apply = map (f: f // { file = "${attrs.config.home}/${f.file}"; });
              description = ''
                Specify a list of files that should be preserved for this user.
                The paths are interpreted relative to {option}`home`.
              '';
            };
            commonMountOptions = mkOption {
              type = with types; listOf (coercedTo str (n: { name = n; }) mountOption);
              default = [ ];
              description = ''
                Specify a list of mount options that should be added to all files and directories
                of this user, for which {option}`how` is set to `bindmount`.

                See also the top level {option}`commonMountOptions` and the invdividual
                {option}`mountOptions` that is available per file / directory.
              '';
            };
            homeGroup = lib.mkOption {
              type = lib.types.str;
              default = config.users.users.${attrs.config.username}.group;
              internal = true;
              readOnly = true;
            };
            homeMode = lib.mkOption {
              type = lib.types.str;
              default = config.users.users.${attrs.config.username}.homeMode;
              internal = true;
              readOnly = true;
            };
          };
        };

      preserveAtSubmodule =
        attrs@{ name, ... }:
        {
          options = {
            persistentStoragePath = mkOption {
              type = types.path;
              default = name;
              description = ''
                Specify the location at which the {option}`directories`, {option}`files`,
                {option}`users.directories` and {option}`users.files` should be preserved.
                Defaults to the name of the parent attribute set.
              '';
            };
            directories = mkOption {
              type =
                with types;
                listOf (
                  coercedTo str (d: { directory = d; }) (submodule [
                    {
                      _module.args = {
                        defaultOwner = "-";
                        defaultGroup = "-";
                        defaultMode = "-";
                      };
                      mountOptions = attrs.config.commonMountOptions;
                    }
                    directoryPath
                  ])
                );
              default = [ ];
              description = ''
                Specify a list of directories that should be preserved.
                The paths are interpreted as absolute paths.
              '';
            };
            files = mkOption {
              type =
                with types;
                listOf (
                  coercedTo str (f: { file = f; }) (submodule [
                    {
                      _module.args = {
                        defaultOwner = "-";
                        defaultGroup = "-";
                        defaultMode = "-";
                      };
                      mountOptions = attrs.config.commonMountOptions;
                    }
                    filePath
                  ])
                );
              default = [ ];
              description = ''
                Specify a list of files that should be preserved.
                The paths are interpreted as absolute paths.
              '';
            };
            users = mkOption {
              type =
                with types;
                attrsWith {
                  placeholder = "user";
                  elemType = submodule [
                    { inherit (attrs.config) commonMountOptions; }
                    userModule
                  ];
                };
              default = { };
              description = ''
                Specify a set of users with corresponding files and directories that
                should be preserved.
              '';
            };
            commonMountOptions = mkOption {
              type = with types; listOf (coercedTo str (n: { name = n; }) mountOption);
              default = [ ];
              description = ''
                Specify a list of mount options that should be added to all files and directories
                under this preservation prefix, for which {option}`how` is set to `bindmount`.

                See also {option}`commonMountOptions` under {option}`users` and the invdividual
                {option}`mountOptions` that is available per file / directory.
              '';
            };
          };
        };
    in
    {
      options.preservation = {
        enable = mkEnableOption "the preservation module";

        preserveAt = mkOption {
          type =
            with types;
            attrsWith {
              placeholder = "path";
              elemType = submodule preserveAtSubmodule;
            };
          default = { };
          description = ''
            Specify a set of locations and the corresponding state that
            should be preserved there.
          '';
        };
      };
    };
}
