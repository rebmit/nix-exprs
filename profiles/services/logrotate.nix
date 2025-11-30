{
  flake.unify.modules."services/logrotate" = {
    nixos = {
      meta = {
        requires = [ "external/preservation" ];
      };

      module =
        { ... }:
        {
          services.logrotate = {
            extraArgs = [
              "-s"
              "/var/lib/logrotate/status"
            ];
          };

          systemd.services.logrotate.serviceConfig = {
            StateDirectory = "logrotate";
          };

          preservation.preserveAt.state.directories = [ "/var/lib/logrotate" ];
        };
    };
  };
}
