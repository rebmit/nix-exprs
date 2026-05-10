{ lib, ... }:

{ host, ... }:

let
  opt = host.options.nix;
in
{
  configs.host =
    { pkgs, ... }:
    {
      options = {
        nix = {
          package = lib.mkPackageOption pkgs "nix" { };

          settings = lib.mkOption {
            type = lib.types.json;
            description = ''
              Configuration for Nix.
            '';
          };

          channel = {
            enable = lib.mkOption {
              type = lib.types.bool;
              description = ''
                Whether to enable Nix channels.
              '';
            };
          };

          nixPath = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = ''
              The default Nix expression search path.
            '';
          };

          registry = lib.mkOption {
            type = lib.types.attrsOf lib.types.json;
            description = ''
              A system-wide flake registry.
            '';
          };
        };
      };

      config = {
        nix = {
          package = lib.mkOverride 1400 pkgs.nixVersions.latest;
          settings = { };
          channel.enable = lib.mkOverride 1400 false;
          nixPath = [ ];
          registry = { };
        };
      };
    };

  modules.darwin =
    { ... }:
    {
      nix = lib.rebmit.modules.mkAliasDefsRecursiveWithPriority {
        inherit (opt)
          package
          settings
          channel
          nixPath
          registry
          ;
      };
    };

  modules.nixos =
    { ... }:
    {
      nix = lib.rebmit.modules.mkAliasDefsRecursiveWithPriority {
        inherit (opt)
          package
          settings
          channel
          nixPath
          registry
          ;
      };
    };
}
