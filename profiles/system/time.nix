{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  unify.modules."system/time" = {
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
