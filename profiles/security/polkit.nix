{
  flake.unify.modules."security/polkit" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
      };

      module =
        { ... }:
        {
          security.polkit.enable = true;
        };
    };
  };
}
