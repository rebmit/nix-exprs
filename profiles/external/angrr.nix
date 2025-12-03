{
  flake.unify.modules."external/angrr" = {
    darwin = {
      module =
        { inputs, ... }:
        {
          imports = [ inputs.angrr.darwinModules.angrr ];
        };
    };
  };
}
