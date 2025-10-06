{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) concatLists isList;
  inherit (lib.modules) mkDefault mkBefore mkAfter;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.strings) concatStringsSep;
  inherit (selfLib.path) concatTwoPaths;
in
{
  flake.modules.nixos.netns =
    {
      pkgs,
      utils,
      ...
    }:
    let
      inherit (utils.systemdUtils.lib) makeJobScript;

      bindMountOptions =
        { name, ... }:
        {
          options = {
            enable = mkEnableOption "the bind mount" // {
              default = true;
            };
            mountPoint = mkOption {
              type = types.str;
              description = ''
                The mount point in the auxiliary mount namespace.
              '';
            };
            hostPath = mkOption {
              type = types.str;
              description = ''
                The host path in the init mount namespace.
              '';
            };
            isReadOnly = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Whether the mounted path should be accessed in read-only mode.
              '';
            };
            recursive = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Whether to perform a recursive bind mount.
              '';
            };
          };

          config = {
            mountPoint = mkDefault name;
            hostPath = mkDefault name;
          };
        };

      mkNetnsOption =
        module:
        mkOption {
          type = types.attrsWith {
            placeholder = "name";
            elemType = types.submoduleWith {
              modules = [ module ];
            };
          };
        };

      attrsToProperties =
        as:
        concatStringsSep " " (
          concatLists (
            mapAttrsToList (
              name: value:
              map (x: "--property=\"${name}=${utils.systemdUtils.lib.toOption x}\"") (
                if isList value then value else [ value ]
              )
            ) as
          )
        );

      mkRuntimeDirectory = netns: service: "netns-${netns}/${service}";
      mkRuntimeDirectoryPath = netns: service: concatTwoPaths "/run" (mkRuntimeDirectory netns service);

      mkNetnsRunWrapper =
        name: cfg:
        pkgs.writeShellApplication {
          name = "netns-run-${name}";
          text = ''
            systemd-run --pipe --pty \
              ${attrsToProperties (cfg.unitConfig or { })} \
              ${attrsToProperties (cfg.serviceConfig or { })} \
              --property="User=$USER" \
              --same-dir \
              --wait "$@"
          '';
        };

      # drop if systemd can do this in the future
      mkRuntimeDirectoryConfiguration =
        netns: service: target: mode:
        let
          runtimeDirectory = mkRuntimeDirectory netns service;
        in
        {
          ExecStartPre = mkBefore [
            "+${
              makeJobScript {
                name = "netns-${netns}-${service}-runtime-directory-setup";
                text = ''
                  mkdir -pv "${target}"
                  chown -Rv "$(stat -c '%u:%g' '${concatTwoPaths "/run" runtimeDirectory}')" "${target}"
                  chmod -v "${mode}" "${target}"
                '';
                enableStrictShellChecks = true;
              }
            }"
          ];
          ExecStopPost = mkAfter [
            "+${
              makeJobScript {
                name = "netns-${netns}-${service}-runtime-directory-clean";
                text = ''
                  rm -rfv "${target}"
                '';
                enableStrictShellChecks = true;
              }
            }"
          ];
          RuntimeDirectory = runtimeDirectory;
        };
    in
    {
      passthru.netns = {
        options = {
          inherit bindMountOptions;
        };

        lib = {
          inherit
            mkNetnsOption
            attrsToProperties
            mkRuntimeDirectoryPath
            mkNetnsRunWrapper
            mkRuntimeDirectoryConfiguration
            ;
        };
      };
    };
}
