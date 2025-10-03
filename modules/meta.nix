{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;

  metaModule = _: {
    options.flake.meta = mkOption {
      type = types.lazyAttrsOf types.anything;
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
