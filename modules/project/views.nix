{ lib, ... }:

{ config, ... }:

let
  inherit (config) outputs;

  viewType = lib.types.submodule (
    { config, ... }:
    {
      options = {
        project = lib.mkOption {
          type = lib.types.functionTo lib.types.raw;
          default = outputs: outputs;
          description = ''
            Projection applied to the outputs.
          '';
        };
        outputs = lib.mkOption {
          type = lib.types.raw;
          readOnly = true;
          default = config.project outputs;
          description = ''
            Projected outputs.
          '';
        };
      };
    }
  );
in
{
  options.views = lib.mkOption {
    type = lib.types.lazyAttrsOf viewType;
    default = { };
    description = ''
      Views over the outputs.
    '';
  };
}
