{
  flake.unify.modules."external/niri-flake" = {
    homeManager.module =
      { inputs, ... }:
      {
        imports = [ inputs.niri-flake.homeModules.niri ];
      };
  };
}
