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

          preservation.preserveAt.state.directories = [ ".local/share/direnv" ];
        };
    };
  };
}
