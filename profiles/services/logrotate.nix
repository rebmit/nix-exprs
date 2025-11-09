{
  unify.modules."services/logrotate" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
        requires = [ "external/preservation" ];
      };

      module = _: {
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
