{
  unify.profiles.programs._.tmux._.user =
    { ... }:
    {
      homeManager =
        { ... }:
        {
          programs.tmux = {
            enable = true;
            aggressiveResize = true;
            baseIndex = 1;
            clock24 = true;
            customPaneNavigationAndResize = true;
            escapeTime = 10;
            focusEvents = true;
            historyLimit = 50000;
            keyMode = "vi";
            mouse = true;
            shortcut = "a";
            terminal = "tmux-256color";
            extraConfig = ''
              set -g set-clipboard on
              set -g renumber-windows on
              set -g bell-action none
              set -g status-right ""

              unbind '"'
              unbind %
              bind '"' split-window -v -c "#{pane_current_path}"
              bind %  split-window -h -c "#{pane_current_path}"

              bind Escape copy-mode

              set -g allow-passthrough on
              set -ga update-environment TERM
              set -ga update-environment TERM_PROGRAM
            '';
          };
        };
    };
}
