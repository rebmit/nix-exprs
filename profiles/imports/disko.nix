{
  flake.unify.modules."imports/disko" = {
    nixos = {
      module =
        { inputs, ... }:
        {
          imports = [ inputs.disko.nixosModules.disko ];
        };
    };
  };
}
