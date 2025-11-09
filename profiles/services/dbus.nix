{
  unify.modules."services/dbus" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
      };

      module = _: {
        services.dbus.implementation = "broker";
      };
    };
  };
}
