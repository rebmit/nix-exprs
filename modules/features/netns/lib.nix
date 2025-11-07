# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/modules/system/boot/systemd/tmpfiles.nix (MIT License)
{ self, lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) concatLists isList;
  inherit (lib.modules) mkBefore mkAfter;
  inherit (lib.options) mkOption;
  inherit (lib.strings) escapeC concatStringsSep concatStrings;
  inherit (self.lib.path) concatPath;

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
  flake.nixosModules.netns =
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
      mkRuntimeDirectoryPath = netns: service: concatPath "/run" (mkRuntimeDirectory netns service);

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
        {
          netns,
          service,
          runtimeDirectory,
          runtimeDirectoryMode ? "0750",
          runtimeDirectoryPreserve ? false,
          runtimeDirectoryPreserveMode ? "0750",
        }:
        let
          dummyRuntimeDirectory = mkRuntimeDirectory netns service;
        in
        {
          ExecStartPre = mkBefore [
            "+${
              makeJobScript {
                name = "netns-${netns}-${service}-runtime-directory-setup";
                text = ''
                  mkdir -pv "${runtimeDirectory}"
                  chown -Rv "$(stat -c '%u:%g' '${concatPath "/run" dummyRuntimeDirectory}')" "${runtimeDirectory}"
                  chmod -v "${runtimeDirectoryMode}" "${runtimeDirectory}"
                '';
                enableStrictShellChecks = true;
              }
            }"
          ];
          ExecStopPost = mkAfter [
            "+${
              makeJobScript {
                name = "netns-${netns}-${service}-runtime-directory-clean";
                text =
                  if runtimeDirectoryPreserve then
                    ''
                      chown -Rv root:root "${runtimeDirectory}"
                      chmod -v "${runtimeDirectoryPreserveMode}" "${runtimeDirectory}"
                    ''
                  else
                    ''
                      rm -rfv "${runtimeDirectory}"
                    '';
                enableStrictShellChecks = true;
              }
            }"
          ];
          RuntimeDirectory = dummyRuntimeDirectory;
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
