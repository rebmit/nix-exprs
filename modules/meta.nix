{ self, lib, ... }:
let
  inherit (lib.types) submoduleWith;
  inherit (lib.options) mkOption;
  inherit (self.lib.types) mkStructuredType;

  metaModule =
    { config, ... }:
    {
      options.meta = mkOption {
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

      config = {
        _module.args.meta = config.meta;
      };
    };
in
{
  flake.flakeModules.meta = metaModule;
}
