# Portions of this file are sourced from
# https://github.com/linyinfeng/dotfiles/blob/7b5cb693088c2996418d44a3f1203680762ed97d/devshell/default.nix (MIT License)
{
  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        commands = map (cmd: cmd // { category = "secrets"; }) [
          {
            package = pkgs.age-plugin-yubikey;
            help = "YubiKey plugin for age";
          }
          {
            package = pkgs.rage;
            help = "Modern encryption tool with small explicit keys";
          }
          {
            package = pkgs.sops;
            help = "Simple and flexible tool for managing secrets";
          }
          {
            name = "sops-update-keys";
            help = "Update keys for all sops file";
            command = ''
              ${pkgs.fd}/bin/fd '.*\.yaml' $PRJ_ROOT/secrets --exec sops updatekeys --yes
            '';
          }
        ];
      };
    };
}
