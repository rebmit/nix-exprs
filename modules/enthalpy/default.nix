{ config, ... }:
{
  flake.nixosModules.enthalpy = config.flake.modules.nixos.enthalpy;
}
