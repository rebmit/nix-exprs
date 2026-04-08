{ inputs, ... }:
let
  inherit (builtins) fromJSON readFile;
in
{
  imports = [
    # keep-sorted start
    "${inputs.flake-parts}/modules/nixosConfigurations.nix"
    # keep-sorted end
  ];

  _module.args.data = fromJSON (readFile ../../infra/data.json);
}
