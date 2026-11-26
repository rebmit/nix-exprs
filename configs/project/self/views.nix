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

      hostConfigurations =
        class:
        lib.mapAttrs (_: host: host.system.${class}.config) (
          lib.filterAttrs (_: host: host.system.class == class) outputs.hosts
        );
    in
    {
      legacyPackages = lib.mapAttrs (_: target: outputs.packages.${target}) targets;
      devShells = lib.mapAttrs (_: target: outputs.devshells.${target}) targets;
      formatter = lib.mapAttrs (_: target: outputs.formatters.${target}.self) targets;
      nixosConfigurations = hostConfigurations "nixos";
      darwinConfigurations = hostConfigurations "darwin";
    };
}
