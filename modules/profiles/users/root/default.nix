{ unify, lib, ... }:
let
  inherit (lib.modules) mkVMOverride;
in
{
  unify.profiles.users._.root =
    { ... }:
    {
      requires = [
        # keep-sorted start
        "profiles/misc/sops-nix"
        "profiles/users/username"
        # keep-sorted end
      ];

      contexts.user =
        { ... }:
        {
          config.userName = "root";
        };

      nixos =
        { config, ... }:
        {
          users.users.root = {
            openssh.authorizedKeys.keys = unify.profiles.users._.rebmit.passthru.authorizedKeys;
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
}
