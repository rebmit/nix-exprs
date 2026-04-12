{
  inputs ? import ./flake,
  lib ? import ./lib { inherit (nixpkgs) lib; },
  nixpkgs ? inputs.nixpkgs,
}:

(lib.rebmit.modules.lattice {
  includes = [ ./modules/configs/projects/self ];
  internalConfigs = [ "project" ];
  inputs = {
    inherit inputs lib;
  };
  registry.rebmit = ./modules;
}).configs.project.outputs
