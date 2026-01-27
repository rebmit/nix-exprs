{ inputs, getSystem, ... }:
{
  unify.profiles.misc._.read-only-pkgs =
    { host, ... }:
    {
      contexts = [ "host" ];

      nixos =
        { ... }:
        {
          imports = [ inputs.nixpkgs.nixosModules.readOnlyPkgs ];

          nixpkgs = {
            inherit ((getSystem host.system).allModuleArgs) pkgs;
          };
        };
    };
}
