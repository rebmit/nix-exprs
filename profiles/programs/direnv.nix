{
  flake.unify.modules."programs/direnv" = {
    homeManager = {
      meta = {
        requires = [ "imports/self/preservation" ];
      };

      module =
        { ... }:
        {
          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
          };

          preservation.preserveAt.state.directories = [ ".local/share/direnv" ];
        };
    };
  };
}
