{
  unify.profiles.system._.services._.vnstatd =
    { ... }:
    {
      requires = [ "features/system/preservation" ];

      nixos =
        { config, ... }:
        {
          services.vnstat.enable = true;

          environment.etc."vnstat.conf".text = ''
            UseUTC 1
          '';

          systemd.services.vnstat = {
            restartTriggers = [ config.environment.etc."vnstat.conf".text ];
          };

          preservation.preserveAt.state.directories = [ "/var/lib/vnstat" ];
        };
    };
}
