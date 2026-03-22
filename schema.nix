{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  options = {
    # keep-sorted start block=yes
    checks = mkOption {
      type = types.lazyAttrsOf (types.lazyAttrsOf types.raw);
      default = { };
      description = ''
        Attribute set of checks grouped by target.
      '';
    };
    darwinConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''
        Instantiated nix-darwin configurations.
      '';
    };
    nixosConfigurations = mkOption {
      type = types.lazyAttrsOf types.raw;
      default = { };
      description = ''
        Instantiated NixOS configurations.
      '';
    };
    packages = mkOption {
      type = types.lazyAttrsOf (types.lazyAttrsOf types.raw);
      default = { };
      description = ''
        Attribute set of packages grouped by target.
      '';
    };
    # keep-sorted end
  };
}
