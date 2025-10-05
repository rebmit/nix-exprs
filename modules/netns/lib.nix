{
  lib,
  selfLib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.lists) concatLists isList;
  inherit (lib.modules) evalModules;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatStringsSep;
  inherit (selfLib.path) concatTwoPaths;
in
{
  flake.modules.nixos.netns =
    {
      options,
      utils,
      ...
    }:
    let
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

      evalSystemdService =
        service:
        (evalModules {
          modules = [
            {
              options.services = mkOption {
                inherit (options.systemd.services) type;
                default = { };
              };
            }
            { config.services.dummy = service; }
          ];
        }).config.services.dummy;

      mkRuntimeDirectory = netns: service: "netns-${netns}/${service}";
      mkRuntimeDirectoryPath = netns: service: concatTwoPaths "/run" "netns-${netns}/${service}";
    in
    {
      passthru.netns = {
        inherit
          mkNetnsOption
          attrsToProperties
          evalSystemdService
          mkRuntimeDirectory
          mkRuntimeDirectoryPath
          ;
      };
    };
}
