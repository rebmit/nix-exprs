{ lib, ... }:

{ project, host, ... }:

let
  cfg = host.config.nixpkgs;
in
{
  configs.host =
    { ... }:
    {
      options = {
        nixpkgs = {
          path = lib.mkOption {
            type = lib.types.path;
            readOnly = true;
            default = project.config.allTargets.${cfg.target}.nixpkgs.path;
            description = ''
              Nixpkgs source tree path for pkgs.
            '';
          };

          pkgs = lib.mkOption {
            type = lib.types.pkgs;
            readOnly = true;
            default = project.config.allTargets.${cfg.target}.pkgs;
            description = ''
              Nixpkgs package set for this host.
            '';
          };

          target = lib.mkOption {
            type = lib.types.str;
            description = ''
              The target name of this host.
            '';
          };
        };
      };

      config = {
        _module.args.pkgs = cfg.pkgs;
      };
    };

  modules.darwin =
    { config, ... }:
    {
      _module.args.pkgs = lib.mkForce cfg.pkgs;

      system = {
        nixpkgsRevision = lib.rebmit.trivial.revisionFromPath cfg.path;
        nixpkgsVersionSuffix = lib.rebmit.trivial.versionSuffixFromRevision config.system.nixpkgsRevision;
      };
    };

  modules.nixos =
    { modulesPath, ... }:
    {
      imports = [ (modulesPath + "/misc/nixpkgs/read-only.nix") ];

      nixpkgs = {
        inherit (cfg) pkgs;
      };
    };
}
