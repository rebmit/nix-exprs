{
  inputs ? import ./npins,
  lib ? import ./lib { },
}:

(lib.rebmit.modules.lattice {
  includes = [ ./modules/configs/projects/self ];
  internalConfigs = [ "project" ];
  inputs = {
    inherit inputs lib;
  };
  registry.rebmit = ./modules;
}).configs.project.outputs
