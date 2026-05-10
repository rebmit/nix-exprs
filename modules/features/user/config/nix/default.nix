{ lib, ... }:

{
  host ? null,
  user,
  ...
}:

let
  cfg = user.config.nix;
in
{
  configs.user =
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
              Adds new directories to the Nix expression search path.
            '';
          };

          registry = lib.mkOption {
            type = lib.types.attrsOf lib.types.json;
            default = { };
            description = ''
              User level flake registry.
            '';
          };
        };
      };

      config = {
        nix = {
          package = lib.mkIf (host != null) host.config.nix.package;
        };
      };
    };

  modules.homeManager =
    { ... }:
    {
      nix = {
        inherit (cfg)
          settings
          nixPath
          registry
          ;

        package = lib.mkForce cfg.package;
      };
    };
}
