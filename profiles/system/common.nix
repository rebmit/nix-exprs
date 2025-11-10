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

      module = _: {
        boot.tmp.useTmpfs = mkDefault true;

        environment = {
          defaultPackages = [ ];
          stub-ld.enable = mkDefault false;
        };

        users.mutableUsers = mkDefault false;

        system.tools.nixos-generate-config.enable = mkDefault false;
      };
    };
  };
}
