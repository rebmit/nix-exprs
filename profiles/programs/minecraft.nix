{
  flake.unify.modules."programs/minecraft" = {
    homeManager = {
      meta = {
        requires = [ "imports/self/preservation" ];
      };

      module =
        { ... }:
        {
          # home.packages = with pkgs; [
          #   prismlauncher
          # ];

          preservation.preserveAt.state.directories = [ ".local/share/PrismLauncher" ];
        };
    };
  };
}
