{ lib, __findFile, ... }:

{
  includes = [
    <rebmit/features/system/config/nix/settings>
    <rebmit/features/system/misc/class>
    <rebmit/features/system/misc/nixpkgs>
    <rebmit/features/system/misc/version>
    <rebmit/features/system/networking/hostname>
  ];

  modules.darwin =
    { ... }:
    {
      documentation = {
        enable = lib.mkDefault false;
        doc.enable = lib.mkDefault false;
        info.enable = lib.mkDefault false;
        man.enable = lib.mkDefault false;
      };

      nixpkgs.flake = {
        setNixPath = lib.mkDefault false;
        setFlakeRegistry = lib.mkDefault false;
      };

      system = {
        tools = {
          enable = lib.mkDefault false;
          darwin-version.enable = lib.mkDefault true;
        };
      };
    };

  modules.nixos =
    { modulesPath, ... }:
    {
      imports = [ (modulesPath + "/profiles/minimal.nix") ];

      nixpkgs.flake = {
        setNixPath = lib.mkDefault false;
        setFlakeRegistry = lib.mkDefault false;
      };

      services.userborn.enable = lib.mkDefault true;

      system = {
        activatable = lib.mkDefault false;
        disableInstallerTools = lib.mkDefault true;
        etc.overlay.enable = lib.mkDefault true;
        nixos-init.enable = lib.mkDefault true;
        tools.nixos-version.enable = lib.mkDefault true;
      };
    };
}
