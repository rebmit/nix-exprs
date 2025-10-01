{
  inputs,
  lib,
  ...
}:
let
  inherit (lib.attrsets) nameValuePair;
in
{
  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    { pkgs, ... }:
    {
      devshells.default = {
        packages = with pkgs; [
          nix-update
        ];
        env = [
          (nameValuePair "DEVSHELL_NO_MOTD" 1)
        ];
      };
    };
}
