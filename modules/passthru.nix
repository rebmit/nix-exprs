{ lib, ... }:
let
  inherit (lib.options) mkOption;

  passthruModule = _: {
    options.passthru = mkOption {
      visible = false;
      description = ''
        This attribute set will be exported as a system attribute.
        You can put whatever you want here.
      '';
    };
  };
in
{
  imports = [ passthruModule ];

  flake.modules.flake.passthru = passthruModule;
}
