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
  inherit (lib.attrsets) mapAttrs recursiveUpdate;
  inherit (lib.modules) mkDefault;
  inherit (lib.options) mkOption;
  inherit (lib.strings) fromJSON;
  inherit (lib.trivial) readFile;
  inherit (lib.types)
    raw
    lazyAttrsOf
    submodule
    listOf
    str
    deferredModule
    attrs
    ;
  inherit (self.lib.types) mkStructuredType;
  inherit (flake-parts-lib) mkSubmoduleOptions;

  data = fromJSON (readFile ../../infra/data.json);
in
{
  options.flake = mkSubmoduleOptions {
    unify.configs.nixos = mkOption {
      type = lazyAttrsOf (
        submodule (
          { name, config, ... }:
          {
            options = {
              meta = mkOption {
                type = submodule {
                  freeformType = mkStructuredType { typeName = "meta"; };
                  options = {
                    tags = mkOption {
                      type = listOf str;
                      default = [ ];
                      description = ''
                        A list of tags attached to this host.  Any module whose tag list shares
                        at least one tag with this host will be automatically imported.
                      '';
                    };
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
                    data = mkOption {
                      type = attrs;
                      default = data.hosts.${config.name} or { };
                      description = ''
                        Attribute sets derived from OpenTofu outputs for this host.
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
      name: cfg:
      let
        inherit (cfg)
          nixpkgs
          module
          system
          meta
          ;

        closure = self.unify.lib.collectModulesForConfig "nixos" {
          inherit name;
          inherit (meta) tags includes excludes;
        };

        unify = recursiveUpdate cfg { meta = { inherit closure; }; };
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
          {
            imports = [ nixpkgs.nixosModules.readOnlyPkgs ];
            nixpkgs = {
              inherit ((getSystem system).allModuleArgs) pkgs;
            };
            networking.hostName = mkDefault name;
          }
        ]
        ++ map (n: self.unify.modules.${n}.nixos.module) closure;
      }
    ) config.flake.unify.configs.nixos;
  };
}
