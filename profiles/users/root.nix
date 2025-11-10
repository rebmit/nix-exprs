{ self, lib, ... }:
let
  inherit (lib.modules) mkVMOverride;
in
{
  flake.unify.modules."users/root" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
        requires = [ "external/sops-nix" ];
      };

      module =
        { config, ... }:
        {
          users.users.root = {
            openssh.authorizedKeys.keys = self.meta.users.rebmit.authorizedKeys;
            hashedPasswordFile = config.sops.secrets."users/root/password".path;
          };

          sops.secrets."users/root/password" = {
            neededForUsers = true;
            sopsFile = config.sops.secretFiles.get "common.yaml";
          };

          virtualisation.vmVariant = {
            users.users.root = {
              password = "password";
              hashedPasswordFile = mkVMOverride null;
            };
          };
        };
    };
  };
}
