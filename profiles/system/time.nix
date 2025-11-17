{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  flake.unify.modules."system/time" = {
    nixos = {
      module =
        { ... }:
        {
          time.timeZone = mkDefault "Asia/Hong_Kong";
        };
    };
  };
}
