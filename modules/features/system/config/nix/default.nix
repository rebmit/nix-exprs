{ lib, ... }:

{ host, ... }:

let
  cfg = host.nix;
in
{
  configs.host =
    { pkgs, ... }:
    {
      options = {
        nix = {
          package = lib.mkPackageOption pkgs "nix" {
            default = [
              "nixVersions"
              "latest"
            ];
          };

          settings = lib.mkOption {
            type = lib.types.json;
            default = { };
            description = ''
              Configuration for Nix.
            '';
          };

          nixPath = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = ''
              The default Nix expression search path.
            '';
          };

          registry = lib.mkOption {
            type = lib.types.attrsOf lib.types.json;
            default = { };
            description = ''
              A system-wide flake registry.
            '';
          };
        };
      };
    };

  modules.darwin =
    { ... }:
    {
      nix = {
        inherit (cfg)
          package
          settings
          nixPath
          registry
          ;

        channel.enable = false;
      };
    };

  modules.nixos =
    { ... }:
    {
      nix = {
        inherit (cfg)
          package
          settings
          nixPath
          registry
          ;

        channel.enable = false;
      };
    };
}
