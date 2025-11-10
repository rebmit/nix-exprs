{ lib, ... }:
let
  inherit (lib.attrsets) nameValuePair;
in
{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        packages = with pkgs; [
          age-plugin-yubikey
          just
          nix-update
          nixos-anywhere
          (opentofu.withPlugins (
            ps: with ps; [
              carlpett_sops
              hashicorp_random
              hashicorp_tls
              terraform-providers-bin.providers.Backblaze.b2
              vultr_vultr
            ]
          ))
          rage
          sops
        ];
        env = [
          (nameValuePair "DEVSHELL_NO_MOTD" 1)
        ];
      };
    };
}
