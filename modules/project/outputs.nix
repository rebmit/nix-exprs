{ lib, ... }:

{
  options = {
    outputs = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = { };
      description = ''
        Flake-like outputs produced by this project.
      '';
    };
  };
}
