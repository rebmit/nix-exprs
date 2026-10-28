{ lib, ... }:

{
  views.flake.project =
    outputs:
    let
      targets = {
        # keep-sorted start block=yes
        aarch64-darwin = "aarch64-darwin";
        aarch64-linux = "aarch64-linux-gnu";
        x86_64-linux = "x86_64-linux-gnu";
        # keep-sorted end
      };
    in
    {
      legacyPackages = lib.mapAttrs (_: target: outputs.packages.${target}) targets;
    };
}
