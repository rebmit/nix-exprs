# Portions of this file are sourced from
# https://codeberg.org/quasigod/unify/src/commit/860b5ac977988b57b4fca57e33ac0f4ef7b8af7f/modules/nixos.nix (MIT License)
{
  inputs,
  self,
  config,
  lib,
  flake-parts-lib,
  getSystem,
  ...
}:
let
  inherit (lib.attrsets) mapAttrs;
  inherit (lib.modules) mkDefault;
  inherit (lib.options) mkOption;
  inherit (lib.types)
    raw
    lazyAttrsOf
    submodule
    listOf
    str
    deferredModule
    ;
  inherit (self.lib.types) mkStructuredType;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in
{
  options.flake = mkSubmoduleOptions {
    unify.configs.nixos = mkOption {
      type = lazyAttrsOf (
        submodule (
          { name, ... }:
          {
            options = {
              meta = mkOption {
                type = submodule {
                  freeformType = mkStructuredType { typeName = "meta"; };
                  options = {
                    includes = mkOption {
                      type = listOf str;
                      default = [ ];
                      description = ''
                        A list of additional modules to import explicitly.  All modules listed here,
                        along with their dependency closures, will be automatically imported.
                      '';
                    };
                    excludes = mkOption {
                      type = listOf str;
                      default = [ ];
                      description = ''
                        A list of modules to exclude.  Any module listed here will be removed
                        from the dependency closure, even if it would otherwise be imported.
                      '';
                    };
                  };
                };
                default = { };
                description = ''
                  Metadata for this NixOS host.
                '';
              };
              name = mkOption {
                type = str;
                default = name;
                description = ''
                  The name of this NixOS configuration.
                '';
              };
              system = mkOption {
                type = str;
                description = ''
                  The host system for this NixOS configuration.
                '';
              };
              module = mkOption {
                type = deferredModule;
                default = { };
                description = ''
                  The deferred module for this NixOS configuration.
                '';
              };
              nixpkgs = mkOption {
                type = raw;
                default = inputs.nixpkgs or (throw "cannot find nixpkgs input");
                description = ''
                  The nixpkgs flake to be used for evaluate this NixOS configuration.
                '';
              };
            };
          }
        )
      );
      default = { };
      description = ''
        A set of NixOS configurations exposed by this flake.
      '';
    };
  };

  config = {
    flake.nixosConfigurations = mapAttrs (
      _: unify:
      let
        inherit (unify)
          meta
          name
          module
          system
          nixpkgs
          ;

        closure = self.unify.lib.collectModulesForConfig "nixos" {
          inherit name;
          inherit (meta) includes excludes;
        };
      in
      nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            self
            inputs
            unify
            ;
        };
        modules = [
          module
          (
            { modulesPath, ... }:
            {
              imports = [
                nixpkgs.nixosModules.readOnlyPkgs
                (modulesPath + "/profiles/minimal.nix")
              ];
              nixpkgs = {
                inherit ((getSystem system).allModuleArgs) pkgs;
              };
              networking.hostName = mkDefault name;
              networking.domain = mkDefault "rebmit.link";
            }
          )
        ]
        ++ map (n: self.unify.modules.${n}.nixos.module) closure;
      }
    ) config.flake.unify.configs.nixos;
  };
}
