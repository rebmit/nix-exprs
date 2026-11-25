{
  inputs ? import ./inputs.nix,
  lib ? import ./lib { source = inputs.nixpkgs; },
  view ? config: config.outputs,
}:

let
  config =
    (lib.rebmit.evalModules {
      class = "project";
      args = { inherit inputs lib; };
      modules = [ ./configs/project/self ];
    }).config;
in
view config
