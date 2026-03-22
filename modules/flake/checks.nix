{ self, lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) isDerivation genAttrs;
  inherit (lib.options) mkOption;
  inherit (self.lib.attrsets) flattenTree;

  checksModule =
    { config, getSystem, ... }:
    {
      _file = ./checks.nix;

      options.checks = mkOption {
        type =
          let
            checkType = types.lazyAttrsOf (
              types.oneOf [
                checkType
                (types.uniq types.raw)
              ]
            );
          in
          types.functionTo checkType;
        default = { };
        apply = f: pkgs: f { inherit pkgs; };
        description = ''
          Checks defined as functions and composed through the module system.
        '';
      };

      config =
        let
          checksForSystem = system: (config.checks (getSystem system).allModuleArgs.pkgs);
        in
        {
          flake = {
            checks = genAttrs config.systems (
              system:
              flattenTree {
                setFilter = s: !isDerivation s;
                leafFilter = isDerivation;
              } (checksForSystem system)
            );
          };
        };
    };
in
{
  imports = [ checksModule ];

  flake.flakeModules.checks = checksModule;
}
