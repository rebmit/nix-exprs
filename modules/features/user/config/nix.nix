{ lib, ... }:

{ user, ... }:

let
  opt = user.options.nix;
in
{
  configs.user =
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

          nixPath = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = ''
              Adds new directories to the Nix expression search path.
            '';
          };

          registry = lib.mkOption {
            type = lib.types.attrsOf lib.types.json;
            description = ''
              User level flake registry.
            '';
          };
        };
      };

      config = {
        nix = {
          package = lib.mkOverride 1400 pkgs.nixVersions.latest;
          settings = { };
          nixPath = [ ];
          registry = { };
        };
      };
    };

  modules.homeManager =
    { ... }:
    {
      nix = lib.rebmit.modules.mkAliasDefsRecursiveWithPriority {
        inherit (opt)
          package
          settings
          nixPath
          registry
          ;
      };
    };
}
