{ lib, ... }:

{ project, host, ... }:

let
  inherit (project.allTargets.${host.nixpkgs.target}) pkgs nixpkgs;
in
{
  configs.host =
    { ... }:
    {
      options = {
        nixpkgs = {
          target = lib.mkOption {
            type = lib.types.str;
            description = ''
              The target name of this host.
            '';
          };
        };
      };

      config = {
        _module.args.pkgs = pkgs;
      };
    };

  modules.darwin =
    { config, ... }:
    let
      cfg = config.system;
    in
    {
      _module.args.pkgs = lib.mkForce pkgs;

      nixpkgs = {
        flake = {
          source = nixpkgs.path;
          setNixPath = true;
          setFlakeRegistry = true;
        };
      };

      system = {
        nixpkgsRevision = nixpkgs.path.revision or nixpkgs.path.rev or null;
        nixpkgsVersionSuffix =
          if cfg.nixpkgsRevision != null then
            ".${lib.substring 0 12 config.system.nixpkgsRevision}"
          else
            "pre-git";
      };
    };

  modules.nixos =
    { modulesPath, ... }:
    {
      imports = [ (modulesPath + "/misc/nixpkgs/read-only.nix") ];

      nixpkgs = {
        inherit pkgs;

        flake = {
          source = nixpkgs.path;
          setNixPath = true;
          setFlakeRegistry = true;
        };
      };
    };
}
