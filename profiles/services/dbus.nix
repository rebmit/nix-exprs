{
  unify.modules."services/dbus" = {
    nixos = {
      meta = {
        tags = [ "base" ];
      };

      module = _: {
        services.dbus.implementation = "broker";
      };
    };
  };
}
