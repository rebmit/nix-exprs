{
  flake.unify.modules."tags/features/multimedia" = {
    nixos = {
      meta = {
        requires = [
          # keep-sorted start
          "services/pipewire"
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
