{ __findFile, ... }:

{ user, ... }:

let
  cfg = user.config.nixpkgs;
in
{
  includes = [
    # keep-sorted start
    ../flakes.nix
    <rebmit/features/user/config/nix>
    <rebmit/features/user/misc/nixpkgs>
    # keep-sorted end
  ];

  configs.user =
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
