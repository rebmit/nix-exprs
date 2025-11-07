{
  inputs,
  config,
  lib,
  partitionStack,
  ...
}:
let
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.modules) mkForce;
in
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  partitions = {
    # keep-sorted start block=yes
    hosts = {
      extraInputsFlake = ../hosts/_flake;
      module = inputs.import-tree ../hosts;
    };
    # keep-sorted end
  };

  flake = optionalAttrs (partitionStack == [ "profiles" ]) (
    let
      partitionAttr =
        partition: attrName: mkForce config.partitions.${partition}.module.flake.${attrName};
    in
    {
      # keep-sorted start block=yes
      nixosConfigurations = partitionAttr "hosts" "nixosConfigurations";
      # keep-sorted end
    }
  );
}
