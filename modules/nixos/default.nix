{ ... }@flake:
{
  flake.nixosModules = {
    default =
      { ... }:
      {
        imports = map (mod: flake.config.flake.modules.nixos.${mod}) [
          # keep-sorted start
          "netns"
          "services/as212982"
          "services/enthalpy"
          "services/usque"
          # keep-sorted end
        ];
      };

    preservation = flake.config.flake.modules.nixos.preservation;
  };
}
