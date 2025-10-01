{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  options.flake.meta = mkOption {
    type = types.lazyAttrsOf types.anything;
    description = ''
      A set of freeform attributes for flake internal usage.
    '';
  };

  config = {
    flake.meta.uri = "github:rebmit/nix-exprs";
  };
}
