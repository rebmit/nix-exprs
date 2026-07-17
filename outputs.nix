{
  inputs ? import ./inputs.nix,
  lib ? import ./lib { path = inputs.nixpkgs; },
}:

(lib.rebmit.modules.lattice {
  includes = [ ./modules/configs/projects/self ];
  internalConfigs = [ "project" ];
  inputs = { inherit inputs lib; };
  registry.rebmit = ./modules;
}).configs.project.config.outputs
