{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  unify.profiles.system._.nixos._.defaults =
    { host, ... }:
    {
      contexts.host = { };

      nixos =
        { ... }:
        {
          boot.tmp.useTmpfs = mkDefault true;

          environment = {
            defaultPackages = mkDefault [ ];
            stub-ld.enable = mkDefault false;
          };

          networking = {
            domain = mkDefault "rebmit.link";
            hostName = mkDefault host.hostName;
            nftables.enable = mkDefault true;
            useNetworkd = mkDefault true;
            useDHCP = mkDefault false;
          };

          services.dbus.implementation = mkDefault "broker";

          time.timeZone = mkDefault "Asia/Hong_Kong";

          users.mutableUsers = mkDefault false;
        };
    };
}
