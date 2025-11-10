{
  flake.unify.modules."security/polkit" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
      };

      module = _: {
        security.polkit.enable = true;
      };
    };
  };
}
