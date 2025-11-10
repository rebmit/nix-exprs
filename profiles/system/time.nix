{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  flake.unify.modules."system/time" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
      };

      module = _: {
        time.timeZone = mkDefault "Asia/Hong_Kong";
      };
    };
  };
}
