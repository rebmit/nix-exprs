{
  system ? builtins.currentSystem,
}:

let
  project = import ./outputs.nix { view = config: config; };
in
project.outputs
// project.views.flake.outputs.legacyPackages.${system}
// {
  devShells = project.views.flake.outputs.devShells.${system};
  formatter = project.views.flake.outputs.formatter.${system};
}
