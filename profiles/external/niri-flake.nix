{ inputs, ... }:
{
  unify.modules."external/niri-flake" = {
    homeManager.module = inputs.niri-flake.homeModules.niri;
  };
}
