baseDirectory:

let
  packageFiles = builtins.mapAttrs (name: _: baseDirectory + "/${name}/package.nix") (
    builtins.readDir baseDirectory
  );
in
final: prev: builtins.mapAttrs (name: path: final.callPackage (import path) { }) packageFiles
