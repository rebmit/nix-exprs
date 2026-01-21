{ self, lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) isDerivation optionalAttrs;
  inherit (lib.options) mkOption;
  inherit (self.lib.attrsets) flattenTree;

  checksModule =
    { options, config, ... }:
    {
      _file = ./checks.nix;

      options.checks = mkOption {
        type = types.submodule (
          { extendModules, ... }:
          {
            freeformType =
              let
                checkType = types.lazyAttrsOf (
                  types.oneOf [
                    checkType
                    types.raw
                  ]
                );
              in
              checkType;

            options.__functor = mkOption {
              internal = true;
              visible = false;
              readOnly = true;
              default =
                _: pkgs:
                let
                  eval = extendModules {
                    specialArgs = { inherit pkgs; };
                  };
                in
                removeAttrs eval.config [ "__functor" ];
              description = ''
                Functor used to evaluate the checks module with a Nixpkgs package set.
              '';
            };

            config._module.args = {
              pkgs = throw ''
                `pkgs` is only available when evaluating checks with a Nixpkgs package set.
              '';
            };
          }
        );
        default = { };
        description = ''
          Checks defined as modules and evaluated with a Nixpkgs package set.
        '';
      };

      config = {
        perSystem = optionalAttrs (options.perSystem.type.getSubOptions [ ] ? checks) (
          { pkgs, ... }:
          {
            checks = flattenTree {
              setFilter = s: !isDerivation s;
              leafFilter = isDerivation;
            } (config.checks pkgs);
          }
        );
      };
    };
in
{
  imports = [ checksModule ];

  flake.flakeModules.checks = checksModule;
}
