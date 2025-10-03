{ config, ... }:
{
  flake.nixosModules.preservation = config.flake.modules.nixos.preservation;
}
