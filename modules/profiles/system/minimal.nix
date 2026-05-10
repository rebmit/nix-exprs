{ lib, __findFile, ... }:

{
  includes = [
    # keep-sorted start
    <rebmit/features/system/misc/class>
    <rebmit/features/system/misc/nixpkgs>
    <rebmit/features/system/misc/version>
    <rebmit/features/system/networking/hostname>
    <rebmit/profiles/system/nix/common>
    # keep-sorted end
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

      boot.bcache.enable = lib.mkDefault false;

      networking = {
        firewall.enable = lib.mkDefault false;
        useNetworkd = lib.mkDefault true;
      };

      nixpkgs.flake = {
        setNixPath = lib.mkDefault false;
        setFlakeRegistry = lib.mkDefault false;
      };

      programs.fuse.enable = lib.mkDefault false;

      services = {
        lvm.enable = lib.mkDefault false;
        userborn.enable = lib.mkDefault true;
      };

      system = {
        activatable = lib.mkDefault false;
        disableInstallerTools = lib.mkDefault true;
        etc.overlay.enable = lib.mkDefault true;
        nixos-init.enable = lib.mkDefault true;
        tools.nixos-version.enable = lib.mkDefault true;
      };
    };
}
