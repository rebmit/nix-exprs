{
  unify.modules."external/sops-nix" = {
    nixos.module =
      { inputs, ... }:
      {
        imports = [ inputs.sops-nix.nixosModules.sops ];
      };
  };
}
