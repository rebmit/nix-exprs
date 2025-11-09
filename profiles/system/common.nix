{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  unify.modules."system/common" = {
    nixos = {
      meta = {
        tags = [ "baseline" ];
      };

      module =
        { pkgs, ... }:
        {
          boot.tmp.useTmpfs = mkDefault true;

          environment = {
            defaultPackages = [ ];
            systemPackages = with pkgs; [
              # keep-sorted start
              _7zz
              binutils
              dnsutils
              fd
              file
              jq
              libtree
              openssl
              psmisc
              ripgrep
              rsync
              strace
              tree
              unar
              unzipNLS
              zip
              # keep-sorted end
            ];
            stub-ld.enable = mkDefault false;
          };

          nix.enable = mkDefault false;

          users.mutableUsers = mkDefault false;

          system.tools.nixos-generate-config.enable = mkDefault false;
        };
    };
  };
}
