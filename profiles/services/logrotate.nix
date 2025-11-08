{
  unify.modules."services/logrotate" = {
    nixos = {
      meta = {
        tags = [ "base" ];
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

        # TODO: fixup
        passthru.preservation.config.logrotate.directories = [ "/var/lib/logrotate" ];
      };
    };
  };
}
