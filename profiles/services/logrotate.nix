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

          preservation.directories = [ "/var/lib/logrotate" ];
        };
    };
  };
}
