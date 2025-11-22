# Portions of this file are sourced from
# https://github.com/NixOS/nixpkgs/blob/0a53886700520c494906ab04a4f9b39d61bfdfb9/nixos/modules/config/getaddrinfo.nix (MIT License)
{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatStringsSep;
in
{
  flake.nixosModules.netns =
    { config, pkgs, ... }:
    let
      inherit (config.lib.netns) mkNetnsOption;
    in
    {
      options.netns = mkNetnsOption (
        { config, ... }:
        let
          cfg = config.getaddrinfo;

          formatTableEntries =
            tableName: table:
            if table == null then
              [ ]
            else
              mapAttrsToList (cidr: val: "${tableName} ${cidr} ${toString val}") table;

          gaiConfText = concatStringsSep "\n" (
            [ "reload ${if cfg.reload then "yes" else "no"}" ]
            ++ formatTableEntries "label" cfg.label
            ++ formatTableEntries "precedence" cfg.precedence
            ++ formatTableEntries "scopev4" cfg.scopev4
          );
        in
        {
          _file = ./getaddrinfo.nix;

          options = {
            getaddrinfo = {
              enable = mkOption {
                type = types.bool;
                default = pkgs.stdenv.hostPlatform.libc == "glibc";
                description = ''
                  Enables custom address sorting configuration for
                  {manpage}`getaddrinfo(3)` according to RFC 3484.
                '';
              };
              reload = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  This keyword controls whether a process checks whether the
                  configuration file has been changed since the last time it
                  was read.  If the value is true, the file is reread.  This
                  might cause problems in multithreaded applications and is
                  generally a bad idea.  The default is false.
                '';
              };
              label = mkOption {
                type = types.nullOr (types.attrsOf types.int);
                default = null;
                description = ''
                  The value is added to the label table used in the RFC 3484
                  sorting.  If any label definition is present in the
                  configuration file, the default table is not used.
                '';
              };
              precedence = mkOption {
                type = types.nullOr (types.attrsOf types.int);
                default = null;
                description = ''
                  This keyword is similar to label, but instead the value is
                  added to the precedence table as specified in RFC 3484.
                  Once again, the presence of a single precedence line in the
                  configuration file causes the default table to not be used.
                '';
              };
              scopev4 = mkOption {
                type = types.nullOr (types.attrsOf types.int);
                default = null;
                description = ''
                  Add another rule to the RFC 3484 scope table for IPv4
                  address.  By default, the scope IDs described in section
                  3.2 in RFC 3438 are used.  Changing these defaults should
                  hardly ever be necessary.
                '';
              };
            };
          };

          config = mkIf (config.enable && cfg.enable) {
            confext."gai.conf".text = gaiConfText;
          };
        }
      );
    };
}
