{ lib, ... }:
let
  inherit (lib.modules) mkVMOverride;
in
{
  unify.profiles.services._.sshd =
    { ... }:
    {
      requires = [ "profiles/misc/sops-nix" ];

      nixos =
        { config, ... }:
        {
          services.openssh = {
            enable = true;
            ports = [
              22
              2222
            ];
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
