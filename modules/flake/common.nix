{ inputs, self, ... }:
let
  inherit (builtins) fromJSON readFile;
in
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/checks.nix"
    "${inputs.flake-parts}/modules/nixosConfigurations.nix"
    # keep-sorted end
  ];

  _module.args.data = fromJSON (readFile ../../infra/data.json);

  perSystem =
    { system, ... }:
    {
      nixpkgs = self.partitions.pkgs.module.allSystems.${system}.nixpkgs;
    };
}
