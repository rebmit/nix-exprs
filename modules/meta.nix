{
  self,
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib.types) submoduleWith;
  inherit (lib.options) mkOption;
  inherit (self.lib.types) mkStructuredType;
  inherit (flake-parts-lib) mkSubmoduleOptions;

  metaModule = _: {
    options.flake = mkSubmoduleOptions {
      meta = mkOption {
        type = submoduleWith {
          modules = [
            {
              freeformType = mkStructuredType { typeName = "meta"; };
            }
          ];
        };
        default = { };
        description = ''
          A set of freeform attributes for flake internal usage.
        '';
      };
    };
  };
in
{
  flake.flakeModules.meta = metaModule;
}
