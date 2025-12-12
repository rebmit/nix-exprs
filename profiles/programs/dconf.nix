{
  flake.unify.modules."programs/dconf" = {
    homeManager = {
      module =
        { pkgs, ... }:
        {
          home.packages = with pkgs; [ dconf ];
        };
    };
  };
}
