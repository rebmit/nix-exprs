{
  flake.unify.modules."services/dbus" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
      };

      module =
        { ... }:
        {
          services.dbus.implementation = "broker";
        };
    };
  };
}
