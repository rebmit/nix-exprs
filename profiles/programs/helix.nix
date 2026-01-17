{ lib, ... }:
let
  inherit (lib.lists) replicate;
in
{
  flake.unify.modules."programs/helix" = {
    homeManager = {
      module =
        { config, pkgs, ... }:
        {
          programs.helix = {
            enable = true;
            defaultEditor = true;
            settings = {
              editor = {
                line-number = "relative";
                cursorline = true;
                bufferline = "multiple";
                color-modes = true;
                lsp.display-messages = true;
                cursor-shape = {
                  insert = "bar";
                  normal = "block";
                  select = "underline";
                };
                indent-guides.render = true;
              };
              keys = {
                normal = {
                  esc = [
                    "keep_primary_selection"
                    "collapse_selection"
                  ];
                  S = ":w";
                  Q = ":q";
                  J = replicate 5 "move_visual_line_down";
                  K = replicate 5 "move_visual_line_up";
                  H = replicate 5 "move_char_left";
                  L = replicate 5 "move_char_right";
                };
                select = {
                  J = replicate 5 "extend_line_down";
                  K = replicate 5 "extend_line_up";
                  H = replicate 5 "extend_char_left";
                  L = replicate 5 "extend_char_right";
                };
              };
            };
          };

          programs.helix.settings.theme = "custom";

          systemd.user.tmpfiles.rules = [
            "L %h/.config/helix/themes/custom.toml - - - - ${config.theme.light.helixTheme}"
          ];

          services.darkman =
            let
              mkScript =
                mode:
                pkgs.writeShellApplication {
                  name = "darkman-switch-helix-${mode}";
                  runtimeInputs = with pkgs; [
                    procps
                  ];
                  text = ''
                    ln --force --symbolic --verbose "${
                      config.theme.${mode}.helixTheme
                    }" "$HOME/.config/helix/themes/custom.toml"
                    pkill -USR1 -u "$USER" hx || true
                  '';
                };
            in
            {
              lightModeScripts.helix = "${lib.getExe (mkScript "light")}";
              darkModeScripts.helix = "${lib.getExe (mkScript "dark")}";
            };
        };
    };
  };
}
