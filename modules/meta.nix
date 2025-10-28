{ lib, selfLib, ... }:
let
  inherit (lib.types) submodule;
  inherit (lib.options) mkOption;
  inherit (selfLib.types) mkStructuredType;

  metaModule = _: {
    options.flake.meta = mkOption {
      type = submodule {
        freeformType = mkStructuredType { typeName = "meta"; };
      };
      description = ''
        A set of freeform attributes for flake internal usage.
      '';
    };
  };
in
{
  imports = [ metaModule ];

  flake.modules.flake.meta = metaModule;

  flake.meta.uri = "github:rebmit/nix-exprs";
}
