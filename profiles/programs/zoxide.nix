{
  flake.unify.modules."programs/zoxide" = {
    homeManager = {
      meta = {
        tags = [ "baseline" ];
        requires = [ "external/preservation" ];
      };

      module = _: {
        programs.zoxide.enable = true;

        preservation.directories = [ ".local/share/zoxide" ];
      };
    };
  };
}
