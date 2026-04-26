{ lib, __findFile, ... }:

{ modules, ... }:

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
          includes = [
            (dir + "/${name}")
            { configs.host = modules.host; }
          ];
        }) (builtins.readDir dir);
    };

  modules.host =
    { ... }:
    {
      networking.domain = lib.mkDefault "rebmit.link";
    };
}
