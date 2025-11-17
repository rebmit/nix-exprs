{
  flake.unify.modules."services/dbus" = {
    nixos = {
      module =
        { ... }:
        {
          services.dbus.implementation = "broker";
        };
    };
  };
}
