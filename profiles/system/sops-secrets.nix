{ lib, ... }:
let
  inherit (lib) types;
  inherit (lib.options) mkOption;
in
{
  unify.modules."system/sops-secrets" = {
    nixos = {
      meta = {
        requires = [ "external/sops-nix" ];
      };

      module =
        { self, config, ... }:
        {
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
          };
        };
    };
  };
}
