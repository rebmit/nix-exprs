{ self, ... }:
let
  inherit (self.lib.misc) mkHardenedService;
in
{
  flake.unify.modules."services/vnstat" = {
    nixos = {
      meta = {
        requires = [ "imports/preservation" ];
      };

      module =
        { config, ... }:
        {
          services.vnstat.enable = true;

          environment.etc."vnstat.conf".text = ''
            UseUTC 1
          '';

          systemd.services.vnstat = mkHardenedService {
            restartTriggers = [ config.environment.etc."vnstat.conf".text ];
          };

          preservation.preserveAt.state.directories = [ "/var/lib/vnstat" ];
        };
    };
  };
}
