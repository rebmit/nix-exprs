{
  flake.unify.modules."services/gnome-keyring" = {
    nixos = {
      module =
        { ... }:
        {
          services.gnome.gnome-keyring.enable = true;
        };
    };
  };
}
