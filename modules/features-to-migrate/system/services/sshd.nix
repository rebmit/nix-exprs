{ lib, ... }:
let
  inherit (builtins) attrValues;
  inherit (lib.modules) mkVMOverride;
in
{
  unify.features.system._.services._.sshd =
    { host, ... }:
    {
      requires = [
        # keep-sorted start
        "features/system/misc/sops-nix"
        "features/system/networking/ports"
        # keep-sorted end
      ];

      contexts.host = {
        ports = {
          "sshd/ssh" = 22;
          "sshd/ssh-alt" = 2222;
        };
      };

      nixos =
        { config, ... }:
        {
          services.openssh = {
            enable = true;
            ports = attrValues {
              inherit (host.ports) "sshd/ssh" "sshd/ssh-alt";
            };
            openFirewall = true;
            settings = {
              Ciphers = [
                "chacha20-poly1305@openssh.com"
                "aes256-gcm@openssh.com"
              ];
              KexAlgorithms = [
                "mlkem768x25519-sha256"
                "sntrup761x25519-sha512"
                "sntrup761x25519-sha512@openssh.com"
              ];
              Macs = [ "hmac-sha2-512-etm@openssh.com" ];
              PasswordAuthentication = false;
              PermitRootLogin = "prohibit-password";
            };
            extraConfig = ''
              ClientAliveInterval 15
              ClientAliveCountMax 4
            '';
            hostKeys = [
              {
                inherit (config.sops.secrets."openssh/ssh-host-ed25519-key") path;
                type = "ed25519";
              }
            ];
          };

          sops.secrets."openssh/ssh-host-ed25519-key" = {
            opentofu = {
              enable = true;
              useHostOutput = true;
              jqPath = "ssh_host_ed25519_key";
            };
            restartUnits = [ "sshd.service" ];
          };

          virtualisation.vmVariant = {
            services.openssh.hostKeys = mkVMOverride [
              {
                path = "/var/lib/nixos/openssh/ssh-host-ed25519-key";
                type = "ed25519";
              }
            ];
          };
        };
    };
}
