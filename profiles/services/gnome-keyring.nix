{
  flake.unify.modules."services/gnome-keyring" = {
    nixos = {
      module =
        { ... }:
        {
          services.gnome.gnome-keyring.enable = true;

          services.gnome.gcr-ssh-agent.enable = false;
        };
    };
  };
}
