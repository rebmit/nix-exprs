{ lib, __findFile, ... }:

{
  includes = [ <rebmit/features/project/devshells> ];

  modules.perTarget =
    { ... }:
    {
      devshells =
        let
          dir = <rebmit/configs/devshells>;
        in
        lib.mapAttrs (name: _: {
          includes = [ (dir + "/${name}") ];
        }) (builtins.readDir dir);
    };
}
