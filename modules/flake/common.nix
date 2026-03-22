{ self, ... }:
let
  inherit (builtins) fromJSON readFile;
in
{
  _module.args.data = fromJSON (readFile ../../infra/data.json);

  perSystem =
    { system, ... }:
    {
      nixpkgs = self.partitions.pkgs.module.allSystems.${system}.nixpkgs;
    };
}
