{ lib, ... }:

{ config, options, ... }:

let
  cfg = config.nixpkgs;
in
{
  options.nixpkgs = {
    pkgs = lib.mkOption {
      type = lib.types.pkgs;
      default = throw ''
        `${options.nixpkgs.pkgs}` is used but is not set.

        Consider explicitly setting `${options.nixpkgs.pkgs}`.
      '';
      description = ''
        Nixpkgs package set for this host.
      '';
    };
  };

  config = {
    _module.args = {
      inherit (cfg) pkgs;
    };

    _.darwin._module.args.pkgs = lib.mkForce cfg.pkgs;

    _.nixos =
      { modulesPath, ... }:
      {
        imports = [ (modulesPath + "/misc/nixpkgs/read-only.nix") ];

        nixpkgs = { inherit (cfg) pkgs; };
      };
  };
}
