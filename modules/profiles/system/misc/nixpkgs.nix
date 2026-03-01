{
  inputs,
  lib,
  getSystem,
  ...
}:
let
  inherit (lib) types;
  inherit (lib.modules) mkForce;
  inherit (lib.options) mkOption;
in
{
  unify.profiles.system._.misc._.nixpkgs =
    { host, ... }:
    let
      pkgs = (getSystem host.system).allModuleArgs.pkgs;
    in
    {
      contexts.host = {
        options = {
          system = mkOption {
            type = types.str;
            description = ''
              The host system of this machine.
            '';
          };
        };
      };

      nixos =
        { ... }:
        {
          imports = [ inputs.nixpkgs.nixosModules.readOnlyPkgs ];

          nixpkgs = { inherit pkgs; };
        };

      darwin =
        { ... }:
        {
          _module.args.pkgs = mkForce pkgs.__splicedPackages;
        };
    };
}
