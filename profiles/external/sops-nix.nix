{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.attrsets)
    filterAttrs
    foldlAttrs
    setAttrByPath
    recursiveUpdate
    ;
  inherit (lib.modules) mkIf mkMerge mkVMOverride;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.strings) splitString;
in
{
  flake.unify.modules."external/sops-nix" = {
    nixos = {
      module =
        {
          inputs,
          self,
          config,
          unify,
          ...
        }@nixos:
        let
          secretsFromOutputs = filterAttrs (_: c: c.opentofu.enable) config.sops.secrets;
        in
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
                  The path to the manually maintained host secret file.
                '';
              };
              opentofu = mkOption {
                type = types.path;
                default = config.sops.secretFiles.get "hosts/opentofu/${unify.name}.yaml";
                description = ''
                  The path to the host secret file exported from OpenTofu.
                '';
              };
            };
            opentofuTemplate = mkOption {
              type = types.attrs;
              default = foldlAttrs (
                acc: _n: v:
                recursiveUpdate acc (
                  setAttrByPath (splitString "/" v.key) (
                    if v.opentofu.useHostOutput then
                      ".hosts.value.\"${unify.name}\".${v.opentofu.jqPath}"
                    else
                      v.opentofu.jqPath
                  )
                )
              ) { } secretsFromOutputs;
              readOnly = true;
              description = ''
                The jq filter template for extracting OpenTofu secrets.
              '';
            };
            secrets = mkOption {
              type = types.attrsOf (
                types.submodule (
                  { config, ... }:
                  {
                    options = {
                      host.enable = mkEnableOption "use per-host secret file";
                      opentofu = {
                        enable = mkEnableOption "use per-host opentofu secert file";
                        useHostOutput = mkEnableOption "extract secret from host-specific output";
                        jqPath = mkOption {
                          type = types.nullOr types.str;
                          default = null;
                          description = ''
                            The jq path that selects the secret value from the OpenTofu output.
                          '';
                        };
                      };
                    };

                    config = mkMerge [
                      {
                        sopsFile = mkIf config.host.enable nixos.config.sops.secretFiles.host;
                      }
                      {
                        sopsFile = mkIf config.opentofu.enable nixos.config.sops.secretFiles.opentofu;
                      }
                    ];
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
  };
}
