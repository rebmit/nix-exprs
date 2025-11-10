{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.modules) mkIf mkVMOverride;
  inherit (lib.options) mkOption mkEnableOption;
in
{
  flake.unify.modules."external/sops-nix" = {
    nixos.module =
      {
        inputs,
        self,
        config,
        unify,
        ...
      }@nixos:
      {
        imports = [ inputs.sops-nix.nixosModules.sops ];

        options.sops = {
          secretFiles = {
            directory = mkOption {
              type = types.path;
              default = "${self}/secrets";
              readOnly = true;
              description = ''
                The directory containing the sops-nix secrets file.
              '';
            };
            get = mkOption {
              type = types.functionTo types.path;
              default = p: "${config.sops.secretFiles.directory}/${p}";
              readOnly = true;
              description = ''
                A function used to convert the relative path of the secret file
                into an absolute path.
              '';
            };
            host = mkOption {
              type = types.path;
              default = config.sops.secretFiles.get "hosts/${unify.name}.yaml";
              description = ''
                The path to per-host secret file.
              '';
            };
          };
          secrets = mkOption {
            type = types.attrsOf (
              types.submodule (
                { config, ... }:
                {
                  options = {
                    host.enable = mkEnableOption "use per-host secret file";
                  };

                  config = {
                    sopsFile = mkIf config.host.enable nixos.config.sops.secretFiles.host;
                  };
                }
              )
            );
          };
        };

        config = {
          sops = {
            age = {
              keyFile = "/var/lib/nixos/sops-nix/sops.key";
              sshKeyPaths = [ ];
            };
            gnupg.sshKeyPaths = [ ];
          };

          virtualisation.vmVariant = {
            system.activationScripts = {
              setupSecrets = mkVMOverride "";
              setupSecretsForUsers = mkVMOverride "";
            };
            systemd.services = {
              sops-install-secrets.enable = mkVMOverride false;
              sops-install-secrets-for-users.enable = mkVMOverride false;
            };
          };
        };
      };
  };
}
