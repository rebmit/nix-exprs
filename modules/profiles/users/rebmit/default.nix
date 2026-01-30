{ lib, ... }:
let
  inherit (lib.maintainers) rebmit;
  inherit (lib.modules) mkDefault mkVMOverride;
in
{
  unify.profiles.users._.rebmit =
    { provider, ... }:
    {
      passthru = {
        inherit (rebmit) name email;
        authorizedKeys = [
          "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDHK6V7pieTigHhvorso7yN3Gy2wu8jYY/qLD+3yh1PLAAAABHNzaDo="
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfKG/KKgC6IaK4uu9zn+0wbF4XXK1pcCP/S37u6OAmJ"
        ];
      };

      requires = [
        # keep-sorted start
        "profiles/misc/sops-nix"
        "profiles/programs/fish/user"
        "profiles/users/username"
        # keep-sorted end
      ];

      contexts.user =
        { ... }:
        {
          config.userName = "rebmit";
        };

      nixos =
        { config, ... }:
        {
          ids.uids.rebmit = 1000;

          users.users.rebmit = {
            description = provider.passthru.name;
            uid = config.ids.uids.rebmit;
            shell = config.programs.fish.package;
            home = "/home/rebmit";
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets."users/rebmit/password".path;
            openssh.authorizedKeys.keys = provider.passthru.authorizedKeys;
            extraGroups = [
              "wheel"
              "pipewire"
            ];
          };

          sops.secrets."users/rebmit/password" = {
            neededForUsers = true;
            sopsFile = config.sops.secretFiles.get "common.yaml";
          };

          virtualisation.vmVariant = {
            users.users.rebmit = {
              password = "password";
              hashedPasswordFile = mkVMOverride null;
            };
          };
        };

      homeManager =
        { ... }:
        {
          programs.git = {
            settings = {
              commit.gpgSign = true;
              user = {
                inherit (provider.passthru) name email;
              };
            };
            signing = {
              format = mkDefault "ssh";
              key = mkDefault "~/.ssh/id_ed25519";
            };
          };
        };
    };
}
