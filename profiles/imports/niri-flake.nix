{
  flake.unify.modules."imports/niri-flake" = {
    homeManager = {
      module =
        { inputs, ... }:
        {
          imports = [ inputs.niri-flake.homeModules.niri ];
        };
    };
  };
}
