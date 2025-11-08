{
  unify.modules."security/polkit" = {
    nixos = {
      meta = {
        tags = [ "base" ];
      };

      module = _: {
        security.polkit.enable = true;
      };
    };
  };
}
