# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/modules/system/boot/systemd/tmpfiles.nix (MIT License)
{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) concatLists isList;
  inherit (lib.modules) mkBefore mkAfter;
  inherit (lib.options) mkOption;
  inherit (lib.strings) escapeC concatStringsSep concatStrings;
  inherit (selfLib.path) concatTwoPaths;

  escapeArgument = escapeC [
    "\t"
    "\n"
    "\r"
    " "
    "\\"
  ];

  settingsEntryToRule = path: entry: ''
    '${entry.type}' '${path}' '${entry.mode}' '${entry.user}' '${entry.group}' '${entry.age}' ${escapeArgument entry.argument}
  '';

  pathsToRules = mapAttrsToList (
    path: types: concatStrings (mapAttrsToList (_type: settingsEntryToRule path) types)
  );
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

      mkTmpfilesRuleFileContent = paths: concatStrings (pathsToRules paths);

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
        lib = {
          inherit
            mkNetnsOption
            attrsToProperties
            mkRuntimeDirectory
            mkRuntimeDirectoryPath
            mkNetnsRunWrapper
            mkTmpfilesRuleFileContent
            mkRuntimeDirectoryConfiguration
            ;
        };
      };
    };
}
