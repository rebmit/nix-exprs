{ lib, ... }:
let
  inherit (builtins) elem attrValues;
  inherit (lib.attrsets) optionalAttrs;
in
{
  unify.features.system._.misc._.documentation =
    { host, ... }:
    let
      workstation = elem "workstation" host.roles;
    in
    {
      requires = [ "features/system/misc/roles" ];

      contexts.host = { };

      nixos =
        { pkgs, ... }:
        {
          documentation = {
            enable = true;
            doc.enable = false;
            info.enable = false;
            man = {
              enable = true;
              generateCaches = false;
              man-db.enable = true;
            };
            nixos.enable = workstation;
          };

          environment.systemPackages = attrValues (
            optionalAttrs workstation {
              inherit (pkgs)
                linux-manual
                man-pages
                man-pages-posix
                ;
            }
          );
        };

      darwin =
        { pkgs, ... }:
        {
          documentation = {
            enable = true;
            doc.enable = false;
            info.enable = false;
            man.enable = true;
          };

          environment.systemPackages = attrValues (
            optionalAttrs workstation {
              inherit (pkgs)
                man-pages
                man-pages-posix
                ;
            }
          );
        };
    };
}
