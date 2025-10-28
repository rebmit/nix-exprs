{
  lib,
  selfLib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib.types) submodule;
  inherit (lib.options) mkOption;
  inherit (selfLib.types) mkStructuredType;
  inherit (flake-parts-lib) mkSubmoduleOptions;
in
{
  options.flake = mkSubmoduleOptions {
    meta = mkOption {
      type = submodule {
        freeformType = mkStructuredType { typeName = "meta"; };
      };
      description = ''
        A set of freeform attributes for flake internal usage.
      '';
    };
  };

  config = {
    flake.meta.uri = "github:rebmit/nix-exprs";
  };
}
