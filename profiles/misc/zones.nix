{
  self,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
  inherit (self.lib.types) mkStructuredType;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in
{
  options.flake = mkSubmoduleOptions {
    meta = mkSubmoduleOptions {
      zones = mkOption {
        type = types.attrsOf (
          types.submodule {
            freeformType = mkStructuredType { typeName = "zone"; };
          }
        );
        default = { };
        description = ''
          A set of DNS zones managed by this flake.
        '';
      };
    };
  };
}
