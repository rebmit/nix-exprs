{
  flake.unify.modules."tags/immutable" = {
    nixos = {
      meta = {
        requires = [
          # keep-sorted start
          "system/etc/overlay"
          "system/userborn"
          # keep-sorted end
        ];
      };
    };

    homeManager = {
      meta = {
        requires = [ ];
      };
    };
  };
}
