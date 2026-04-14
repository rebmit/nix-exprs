{ lib, __findFile, ... }:

{
  includes = [ <rebmit/features/project/hosts> ];

  configs.project =
    { ... }:
    {
      hosts =
        let
          dir = <rebmit/configs/hosts>;
        in
        lib.mapAttrs (name: _: {
          includes = [ (dir + "/${name}") ];
        }) (builtins.readDir dir);
    };
}
