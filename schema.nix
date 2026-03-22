{ lib, ... }:
let
  inherit (builtins) mapAttrs;
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  options = {
    # keep-sorted start block=yes
    checks = mkOption {
      type = types.lazyAttrsOf (types.lazyAttrsOf types.package);
      default = { };
      description = ''
        Derivations per target system used for checks.
      '';
    };
    darwinConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''
        Instantiated nix-darwin configurations.
      '';
    };
    devShells = mkOption {
      type = types.lazyAttrsOf (types.lazyAttrsOf types.package);
      default = { };
      description = ''
        Development shells per target system.
      '';
    };
    formatter = mkOption {
      type = types.lazyAttrsOf types.package;
      default = { };
      description = ''
        Formatter per target system.
      '';
    };
    legacyPackages = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''
        Nixpkgs package sets per target system.
      '';
    };
    nixosConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''
        Instantiated NixOS configurations.
      '';
    };
    overlays = mkOption {
      type = types.lazyAttrsOf (
        types.uniq (types.functionTo (types.functionTo (types.lazyAttrsOf types.raw)))
      );
      default = { };
      apply = mapAttrs (
        _: f: final: prev:
        f final prev
      );
      description = ''
        Nixpkgs overlays.
      '';
    };
    # keep-sorted end
  };
}
