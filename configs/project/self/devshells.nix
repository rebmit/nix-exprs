{ lib, ... }:

{
  perTarget =
    { ... }:
    {
      devshells =
        let
          dir = ../../dev;
        in
        lib.mapAttrs (name: _: { imports = [ (dir + "/${name}") ]; }) (builtins.readDir dir);
    };
}
