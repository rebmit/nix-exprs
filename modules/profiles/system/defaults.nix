{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  unify.profiles.system._.defaults =
    { ... }:
    {
      nixos =
        { ... }:
        {
          boot.tmp.useTmpfs = mkDefault true;

          environment.stub-ld.enable = mkDefault false;

          services.dbus.implementation = mkDefault "broker";

          time.timeZone = mkDefault "Asia/Hong_Kong";

          users.mutableUsers = mkDefault false;
        };
    };
}
