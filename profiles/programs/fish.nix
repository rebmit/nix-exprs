{
  flake.unify.modules."programs/fish" = {
    nixos = {
      module =
        { ... }:
        {
          programs.fish = {
            enable = true;
            useBabelfish = true;
            generateCompletions = false;
          };
        };
    };

    homeManager = {
      meta = {
        requires = [ "imports/self/preservation" ];
      };

      module =
        { pkgs, ... }:
        {
          programs.fish = {
            enable = true;
            generateCompletions = false;
            plugins = [
              {
                name = "tide";
                inherit (pkgs.fishPlugins.tide) src;
              }
            ];
            shellInit = ''
              set fish_greeting

              function fish_user_key_bindings
                fish_vi_key_bindings
                bind f accept-autosuggestion
              end

              string replace -r '^' 'set -g ' < ${pkgs.fishPlugins.tide.src}/functions/tide/configure/icons.fish | source
              string replace -r '^' 'set -g ' < ${pkgs.fishPlugins.tide.src}/functions/tide/configure/configs/lean.fish | source
              string replace -r '^' 'set -g ' < ${pkgs.fishPlugins.tide.src}/functions/tide/configure/configs/lean_16color.fish | source
              set -g tide_prompt_add_newline_before false

              fish_config theme choose fish\ default
              set fish_color_autosuggestion white
            '';
          };

          preservation.preserveAt.state.directories = [ ".local/share/fish" ];
        };
    };
  };
}
