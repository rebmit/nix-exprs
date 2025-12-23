{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.options) mkOption;

  nixosModulesModule =
    { moduleLocation, ... }:
    {
      _file = ./nixos-modules.nix;

      options.flake.nixosModules = mkOption {
        type = types.lazyAttrsOf types.deferredModule;
        default = { };
        apply = mapAttrs (
          k: v: {
            _class = "nixos";
            _file = "${toString moduleLocation}#nixosModules.${k}";
            # https://github.com/hercules-ci/flake-parts/pull/251
            key = "${toString moduleLocation}#nixosModules.${k}";
            imports = [ v ];
          }
        );
        description = ''
          NixOS modules.
        '';
      };
    };
in
{
  imports = [ nixosModulesModule ];

  flake.flakeModules.nixosModules = nixosModulesModule;
}
