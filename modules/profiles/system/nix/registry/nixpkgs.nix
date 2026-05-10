{ __findFile, ... }:

{ host, ... }:

let
  cfg = host.config.nixpkgs;
in
{
  includes = [
    # keep-sorted start
    ../flakes.nix
    <rebmit/features/system/config/nix>
    <rebmit/features/system/misc/nixpkgs>
    # keep-sorted end
  ];

  configs.host =
    { ... }:
    {
      nix = {
        nixPath = [ "nixpkgs=flake:nixpkgs" ];
        registry.nixpkgs.to = {
          type = "path";
          path = cfg.path;
        };
      };
    };
}
