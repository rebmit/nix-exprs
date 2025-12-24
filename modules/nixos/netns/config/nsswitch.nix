# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/modules/config/nsswitch.nix (MIT License)
{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.modules) mkIf mkMerge mkOrder;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatStringsSep;
in
{
  flake.modules.nixos.netns =
    { config, ... }:
    let
      inherit (config.lib.netns) mkNetnsOption;

      globalNssDatabases = config.system.nssDatabases;
    in
    {
      options.netns = mkNetnsOption (
        { config, ... }:
        {
          _file = ./nsswitch.nix;

          options = {
            nssDatabases = {
              hosts = mkOption {
                type = types.listOf types.str;
                default = [ ];
                description = ''
                  List of hosts entries to configure in {file}`/etc/nsswitch.conf`.
                  Note that "files" is always prepended, and "dns" and "myhostname" are always appended.
                  This option only takes effect if nscd is enabled.
                '';
              };
            };
          };

          config = mkIf config.enable {
            nssDatabases = {
              hosts = mkMerge [
                (mkOrder 400 [ "mymachines" ])
                (mkOrder 998 [ "files" ])
                (mkOrder 999 [ "myhostname" ])
                (mkOrder 1499 [ "dns" ])
              ];
            };

            confext."nsswitch.conf".text = ''
              passwd:    ${concatStringsSep " " globalNssDatabases.passwd}
              group:     ${concatStringsSep " " globalNssDatabases.group}
              shadow:    ${concatStringsSep " " globalNssDatabases.shadow}
              sudoers:   ${concatStringsSep " " globalNssDatabases.sudoers}

              hosts:     ${concatStringsSep " " config.nssDatabases.hosts}
              networks:  files

              ethers:    files
              services:  ${concatStringsSep " " globalNssDatabases.services}
              protocols: files
              rpc:       files
            '';
          };
        }
      );
    };
}
