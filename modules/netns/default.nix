{ config, ... }:
{
  flake.nixosModules.netns = config.flake.modules.nixos.netns;
}
