{
  flake.unify.modules."external/disko" = {
    nixos = {
      module =
        { inputs, ... }:
        {
          imports = [ inputs.disko.nixosModules.disko ];
        };
    };
  };
}
