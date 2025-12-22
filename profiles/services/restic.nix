{ lib, meta, ... }:
let
  inherit (lib.modules) mkVMOverride;
in
{
  flake.unify.modules."services/restic" = {
    nixos = {
      meta = {
        requires = [
          "imports/preservation"
          "imports/sops-nix"
        ];
      };

      module =
        { config, unify, ... }:
        {
          services.restic.backups.b2 = {
            repository = "b2:${meta.data.hosts.${unify.name}.b2_backup_bucket_name}";
            environmentFile = config.sops.templates."restic/b2/envs".path;
            passwordFile = config.sops.secrets."restic/password".path;
            initialize = true;
            paths = [ "/persist/state" ];
            extraBackupArgs = [
              "--one-file-system"
              "--exclude-caches"
              "--no-scan"
              "--retry-lock 2h"
            ];
            pruneOpts = [
              "--keep-daily 7"
              "--keep-weekly 4"
            ];
            timerConfig = {
              OnCalendar = "daily";
              RandomizedDelaySec = "4h";
              FixedRandomDelay = true;
              Persistent = true;
            };
          };

          systemd.services.restic-backups-b2.serviceConfig.Environment = [ "GOGC=20" ];

          sops.secrets."restic/password" = {
            opentofu = {
              enable = true;
              useHostOutput = true;
              jqPath = "restic_password";
            };
            restartUnits = [ "restic-backups-b2.service" ];
          };

          sops.secrets."restic/b2/application-key-id" = {
            opentofu = {
              enable = true;
              useHostOutput = true;
              jqPath = "b2_backup_application_key_id";
            };
            restartUnits = [ "restic-backups-b2.service" ];
          };

          sops.secrets."restic/b2/application-key" = {
            opentofu = {
              enable = true;
              useHostOutput = true;
              jqPath = "b2_backup_application_key";
            };
            restartUnits = [ "restic-backups-b2.service" ];
          };

          sops.templates."restic/b2/envs".content = ''
            B2_ACCOUNT_ID="${config.sops.placeholder."restic/b2/application-key-id"}"
            B2_ACCOUNT_KEY="${config.sops.placeholder."restic/b2/application-key"}"
          '';

          preservation.preserveAt.cache.directories = [ "/var/cache/restic-backups-b2" ];

          virtualisation.vmVariant = {
            services.restic.backups = mkVMOverride { };
          };
        };
    };
  };
}
