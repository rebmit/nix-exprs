{ lib, meta, ... }:
let
  inherit (lib.modules) mkVMOverride mkDefault;
in
{
  meta.users.rebmit = {
    name = "Lu Wang";
    email = "rebmit@rebmit.moe";
    authorizedKeys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDHK6V7pieTigHhvorso7yN3Gy2wu8jYY/qLD+3yh1PLAAAABHNzaDo="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfKG/KKgC6IaK4uu9zn+0wbF4XXK1pcCP/S37u6OAmJ"
    ];
  };

  flake.unify.modules."users/rebmit" = {
    nixos = {
      meta = {
        requires = [
          "imports/sops-nix"
          "programs/fish"
        ];
      };

      module =
        { config, ... }:
        {
          ids.uids.rebmit = 1000;

          users.users.rebmit = {
            description = meta.users.rebmit.name;
            uid = config.ids.uids.rebmit;
            shell = config.programs.fish.package;
            home = "/home/rebmit";
            isNormalUser = true;
            hashedPasswordFile = config.sops.secrets."users/rebmit/password".path;
            openssh.authorizedKeys.keys = meta.users.rebmit.authorizedKeys;
            extraGroups = [
              "wheel"
              "pipewire"
            ];
          };

          nix.settings.trusted-users = [ "rebmit" ];

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
    };

    homeManager = {
      meta = {
        configs = [ "rebmit" ];
        requires = [ "programs/fish" ];
      };

      module =
        { ... }:
        {
          programs.git = {
            settings = {
              commit.gpgSign = true;
              user = {
                inherit (meta.users.rebmit) name email;
              };
            };
            signing = {
              format = mkDefault "ssh";
              key = mkDefault "~/.ssh/id_ed25519";
            };
          };
        };
    };
  };
}
