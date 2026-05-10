{ lib, ... }:

{
  project,
  host ? null,
  user,
  ...
}:

let
  cfg = user.config.nixpkgs;
in
{
  configs.user =
    { ... }:
    {
      options = {
        nixpkgs = {
          path = lib.mkOption {
            type = lib.types.pathInStore;
            readOnly = true;
            default =
              if host != null then
                host.config.nixpkgs.path
              else
                project.config.allTargets.${cfg.target}.nixpkgs.path;
            description = ''
              Nixpkgs source tree path for pkgs.
            '';
          };

          pkgs = lib.mkOption {
            type = lib.types.pkgs;
            readOnly = true;
            default =
              if host != null then host.config.nixpkgs.pkgs else project.config.allTargets.${cfg.target}.pkgs;
            description = ''
              Nixpkgs package set for this user.
            '';
          };

          target = lib.mkOption {
            type = lib.types.str;
            description = ''
              The target name of this user.
            '';
          };
        };
      };

      config = {
        _module.args.pkgs = cfg.pkgs;
      };
    };

  modules.homeManager =
    { ... }:
    {
      _module.args.pkgs = lib.mkForce cfg.pkgs;
    };
}
