{ ... }:
{
  flake.overlays = {
    default =
      _final: prev:
      prev.lib.packagesFromDirectoryRecursive {
        inherit (prev) callPackage;
        directory = ../../pkgs;
      };
  };
}
