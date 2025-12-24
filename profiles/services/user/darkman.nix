{
  flake.unify.modules."services/user/darkman" = {
    homeManager = {
      meta = {
        requires = [ "imports/self/preservation" ];
      };

      module =
        {
          config,
          pkgs,
          ...
        }@hm:
        let
          defaultMode = pkgs.writeText "darkman-default-mode" "light";
        in
        {
          services.darkman.enable = true;

          preservation.preserveAt.state.directories = [ ".cache/darkman" ];

          systemd.user.tmpfiles.rules = [
            "C %h/.cache/darkman/mode.txt - - - - ${defaultMode}"
            "z %h/.cache/darkman/mode.txt 644 - - -"
          ];

          home.packages = with pkgs; [
            (writeShellApplication {
              name = "toggle-theme";
              runtimeInputs = [ config.services.darkman.package ];
              text = ''
                darkman toggle
              '';
            })
          ];

          home.activation.restartDarkman = hm.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if ${config.systemd.user.systemctlPath} --user is-active darkman; then
              ${config.systemd.user.systemctlPath} --user restart darkman
            fi
          '';

          systemd.user.services.darkman.Unit = {
            After = [ "graphical-session.target" ];
            Requisite = [ "graphical-session.target" ];
          };
        };
    };
  };
}
