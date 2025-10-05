# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/modules/config/networking.nix (MIT License)
{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) attrNames filterAttrs;
  inherit (lib.lists) optional;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatStringsSep concatMapStrings;
in
{
  flake.modules.nixos.netns =
    { config, ... }:
    let
      inherit (config.passthru.netns) mkNetnsOption;

      inherit (config.networking) hostName domain;
    in
    {
      options.netns = mkNetnsOption (
        { config, ... }:
        {
          _file = ./hosts.nix;

          options = {
            hosts = mkOption {
              type = types.attrsOf (types.listOf types.str);
              default = { };
              description = ''
                Per-netns locally defined maps of hostnames to IP addresses.
              '';
            };
            extraHosts = mkOption {
              type = types.lines;
              default = "";
              description = ''
                Additional verbatim entries to be appended to {file}`/etc/hosts`.
              '';
            };
          };

          config = mkIf config.enable {
            hosts =
              let
                hostnames =
                  optional (hostName != "" && domain != null) "${hostName}.${domain}"
                  ++ optional (hostName != "") hostName;
              in
              {
                "127.0.0.2" = hostnames;
              };

            confext."hosts".text =
              let
                localhostHosts = ''
                  127.0.0.1 localhost
                  ::1 localhost
                '';
                stringHosts =
                  let
                    oneToString = set: ip: ip + " " + concatStringsSep " " set.${ip} + "\n";
                    allToString = set: concatMapStrings (oneToString set) (attrNames set);
                  in
                  allToString (filterAttrs (_: v: v != [ ]) config.hosts);
                inherit (config) extraHosts;
              in
              localhostHosts + stringHosts + extraHosts;
          };
        }
      );
    };
}
