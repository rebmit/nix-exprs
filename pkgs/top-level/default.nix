{
  # Path to the Nixpkgs source tree to be imported.
  path ? (import ../../inputs.nix).nixpkgs,

  # The system packages will be built on. See the manual for the
  # subtle division of labor between these two `*System`s and the three
  # `*Platform`s.
  localSystem ? builtins.currentSystem,

  # The system packages will ultimately be run on.
  crossSystem ? localSystem,

  # Allow a configuration attribute set to be passed in as an argument.
  config ? { },

  # List of overlays layers used to extend Nixpkgs.
  overlays ? [ ],

  # List of overlays to apply to target packages only.
  crossOverlays ? [ ],
}:

let
  pkgs = import path {
    inherit
      localSystem
      crossSystem
      config
      crossOverlays
      ;

    overlays = [
      (import ./lib.nix)
      (import ./all-packages.nix)
    ]
    ++ overlays;
  };
in
pkgs
