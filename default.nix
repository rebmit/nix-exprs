{
  system ? builtins.currentSystem,
}:

let
  project = import ./outputs.nix { view = config: config; };
in
project.outputs // project.views.flake.outputs.legacyPackages.${system}
