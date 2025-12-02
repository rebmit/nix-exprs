{ lib, ... }:
let
  inherit (lib.modules) mkDefault;
in
{
  flake.unify.modules."system/common" = {
    nixos = {
      module =
        { self, ... }:
        {
          boot.tmp.useTmpfs = mkDefault true;

          environment = {
            defaultPackages = [ ];
            stub-ld.enable = mkDefault false;
          };

          users.mutableUsers = mkDefault false;

          system.configurationRevision = self.rev or "dirty";

          system.tools = {
            nixos-generate-config.enable = mkDefault false;
            nixos-option.enable = mkDefault false;
          };
        };
    };
  };
}
