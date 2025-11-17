{
  flake.unify.modules."programs/zoxide" = {
    homeManager = {
      meta = {
        requires = [ "external/preservation" ];
      };

      module =
        { ... }:
        {
          programs.zoxide.enable = true;

          preservation.directories = [ ".local/share/zoxide" ];
        };
    };
  };
}
