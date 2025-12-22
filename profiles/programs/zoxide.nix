{
  flake.unify.modules."programs/zoxide" = {
    homeManager = {
      meta = {
        requires = [ "imports/preservation" ];
      };

      module =
        { ... }:
        {
          programs.zoxide.enable = true;

          preservation.preserveAt.state.directories = [ ".local/share/zoxide" ];
        };
    };
  };
}
