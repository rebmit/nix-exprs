# Portions of this file are sourced from
# https://codeberg.org/quasigod/unify/src/commit/860b5ac977988b57b4fca57e33ac0f4ef7b8af7f/modules/nixos.nix (MIT License)
{ self, lib, ... }:
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
in
{
  flake.flakeModules.unify =
    {
      inputs,
      self,
      config,
      getSystem,
      ...
    }:
    {
      options.unify.config = {
        nixpkgs = mkOption {
          type = raw;
          default = inputs.nixpkgs or (throw "cannot find nixpkgs input");
          description = ''
            The nixpkgs flake to be used for evaluate NixOS configuration.
          '';
        };
      };

      options.unify.hosts.nixos = mkOption {
        type = lazyAttrsOf (
          submodule (
            { name, ... }:
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
                  default = config.unify.config.nixpkgs;
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

            closure = config.unify.lib.collectModulesForHost "nixos" {
              host = name;
              inherit (meta) tags includes excludes;
            } config.unify.modules;
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              # TODO: remove after test
              inherit closure;
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
            ++ map (n: self.modules.nixos.${n}) closure;
          }
        ) config.unify.hosts.nixos;
      };
    };
}
