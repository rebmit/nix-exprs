{ config, ... }:
let
  niri-flake = config.partitions.hosts.extraInputs.niri-flake;
in
{
  unify.modules."external/niri-flake" = {
    homeManager.module = niri-flake.homeModules.niri;
  };
}
