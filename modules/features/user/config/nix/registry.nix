{ lib, __findFile, ... }:

{
  host ? null,
  user,
  ...
}:

{
  includes = [
    ./.

    <rebmit/features/user/misc/nixpkgs>
  ];

  configs.user =
    { ... }:
    {
      nix = {
        nixPath = lib.mkIf (host == null) [
          "nixpkgs=flake:nixpkgs"
        ];

        registry = {
          nixpkgs = lib.mkIf (host == null) {
            to = {
              type = "path";
              path = user.nixpkgs.path;
            };
          };
        };
      };
    };
}
