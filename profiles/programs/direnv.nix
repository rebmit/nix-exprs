{
  flake.unify.modules."programs/direnv" = {
    homeManager = {
      meta = {
        requires = [ "external/preservation" ];
      };

      module =
        { ... }:
        {
          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
          };

          preservation.directories = [ ".local/share/direnv" ];
        };
    };
  };
}
