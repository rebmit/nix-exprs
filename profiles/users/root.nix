{ self, ... }:
{
  unify.modules."users/root" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
        requires = [
          "external/sops-nix"
          "system/sops-secrets"
        ];
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
        };
    };
  };
}
