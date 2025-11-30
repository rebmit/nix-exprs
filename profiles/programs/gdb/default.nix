{ lib, ... }:
let
  inherit (lib.lists) optionals;
in
{
  flake.unify.modules."programs/gdb" = {
    homeManager = {
      meta = {
        requires = [ "external/preservation" ];
      };

      module =
        {
          config,
          pkgs,
          nixosConfig,
          ...
        }:
        {
          home.packages = with pkgs; [
            gdb
          ];

          xdg = {
            configFile."gdb/gdbinit".source = ./gdbinit;
            stateFile."gdb/.keep".text = "";
          };

          home.sessionVariables = {
            GDBHISTFILE = "${config.xdg.stateHome}/gdb/gdb_history";
          };

          preservation.preserveAt.state.directories = [ ".local/state/gdb" ];

          preservation.preserveAt.cache.directories =
            optionals (nixosConfig != null && nixosConfig.environment.debuginfodServers != [ ])
              [
                ".cache/debuginfod_client"
              ];
        };
    };
  };
}
