{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  unify.profiles.system._.misc._.defaults =
    { ... }:
    {
      nixos =
        { ... }:
        {
          boot.tmp.useTmpfs = true;

          environment.stub-ld.enable = false;

          services.dbus.implementation = "broker";

          time.timeZone = mkDefault "Asia/Hong_Kong";

          users.mutableUsers = false;
        };
    };
}
